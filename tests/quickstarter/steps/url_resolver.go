package steps

import (
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/opendevstack/ods-core/tests/quickstarter/logger"
)

// RouteCache caches route lookups to avoid repeated queries
type RouteCache struct {
	routes map[string]string // key: namespace/service -> value: route URL
	mu     sync.RWMutex
}

var routeCache = &RouteCache{
	routes: make(map[string]string),
}

// ServiceURL represents a parsed internal service URL
type ServiceURL struct {
	ServiceName string
	Namespace   string
	Port        string
	Path        string
	Scheme      string
}

// ResolveServiceURL intelligently resolves a service URL based on execution environment
// Strategy:
// 1. If URL is not an internal service URL (.svc.cluster.local), return as-is
// 2. Check if a route exists for the service -> use route URL
// 3. If running in cluster (Jenkins) -> use internal service DNS
// 4. If running locally -> setup port-forward and use localhost
func ResolveServiceURL(t *testing.T, rawURL string, tmplData TemplateData) string {
	// First, render any template variables
	rendered := renderTemplate(t, rawURL, tmplData)

	// Check if this is an internal service URL
	if !isInternalServiceURL(rendered) {
		// Already an external URL (http://, https://, or route)
		return rendered
	}

	// Parse the internal service URL
	serviceURL, err := parseInternalServiceURL(rendered)
	if err != nil {
		// Can't parse, return as-is and let it fail naturally
		logger.Warn("Could not parse service URL: %s (error: %v)", rendered, err)
		return rendered
	}

	logger.Running(fmt.Sprintf("Resolving service URL: %s/%s:%s", serviceURL.Namespace, serviceURL.ServiceName, serviceURL.Port))

	// Strategy 1: Try to get route (works everywhere)
	if routeURL := getRouteURL(serviceURL.ServiceName, serviceURL.Namespace); routeURL != "" {
		finalURL := routeURL + serviceURL.Path
		logger.Success(fmt.Sprintf("Using route: %s", finalURL))
		return finalURL
	}

	// Strategy 2: If in cluster, use service DNS
	if isRunningInCluster() {
		logger.Success(fmt.Sprintf("Running in cluster, using service DNS: %s", rendered))
		return rendered
	}

	// Strategy 3: Local development - setup port-forward
	logger.Running("Running locally, setting up port-forward...")
	localPort, err := EnsurePortForward(serviceURL.ServiceName, serviceURL.Namespace, serviceURL.Port)
	if err != nil {
		if t != nil {
			t.Fatalf("Failed to setup port-forward for %s/%s:%s: %v",
				serviceURL.Namespace, serviceURL.ServiceName, serviceURL.Port, err)
		}
		panic(fmt.Sprintf("Failed to setup port-forward: %v", err))
	}

	localURL := fmt.Sprintf("http://localhost:%d%s", localPort, serviceURL.Path)
	logger.Success(fmt.Sprintf("Using port-forward: %s", localURL))
	return localURL
}

// isInternalServiceURL checks if a URL is an internal Kubernetes service URL
func isInternalServiceURL(url string) bool {
	return strings.Contains(url, ".svc.cluster.local") || strings.Contains(url, ".svc:")
}

// parseInternalServiceURL parses an internal service URL into its components
// Expected format: http://service.namespace.svc.cluster.local:port/path
// Also supports: http://service.namespace.svc:port/path
func parseInternalServiceURL(url string) (*ServiceURL, error) {
	// Pattern to match service URLs
	// Group 1: scheme (http/https)
	// Group 2: service name
	// Group 3: namespace
	// Group 4: port
	// Group 5: path (optional)
	pattern := `^(https?)://([^.]+)\.([^.]+)\.svc(?:\.cluster\.local)?:(\d+)(.*)$`
	re := regexp.MustCompile(pattern)

	matches := re.FindStringSubmatch(url)
	if matches == nil {
		return nil, fmt.Errorf("URL does not match expected service URL format")
	}

	return &ServiceURL{
		Scheme:      matches[1],
		ServiceName: matches[2],
		Namespace:   matches[3],
		Port:        matches[4],
		Path:        matches[5],
	}, nil
}

// isRunningInCluster detects if we're running inside a Kubernetes/OpenShift cluster
func isRunningInCluster() bool {
	// Check for Kubernetes service environment variable
	if os.Getenv("KUBERNETES_SERVICE_HOST") != "" {
		return true
	}

	// Check for service account token (mounted in pods)
	if _, err := os.Stat("/var/run/secrets/kubernetes.io/serviceaccount/token"); err == nil {
		return true
	}

	return false
}

// getRouteURL queries OpenShift for a route and returns the URL if it exists
func getRouteURL(serviceName, namespace string) string {
	cacheKey := fmt.Sprintf("%s/%s", namespace, serviceName)

	// Check cache first
	routeCache.mu.RLock()
	if cached, exists := routeCache.routes[cacheKey]; exists {
		routeCache.mu.RUnlock()
		return cached
	}
	routeCache.mu.RUnlock()

	// Query OpenShift for route
	result := queryRoute(serviceName, namespace)

	// Cache the result (even if empty, to avoid repeated failed queries)
	routeCache.mu.Lock()
	routeCache.routes[cacheKey] = result
	routeCache.mu.Unlock()

	return result
}

// queryRoute performs the actual OpenShift route query
func queryRoute(serviceName, namespace string) string {
	// Get route host
	cmd := exec.Command("oc", "get", "route", serviceName,
		"-n", namespace,
		"-o", "jsonpath={.spec.host}",
		"--ignore-not-found")

	output, err := cmd.CombinedOutput()
	if err != nil {
		// Route doesn't exist or error querying
		return ""
	}

	host := strings.TrimSpace(string(output))
	if host == "" {
		return ""
	}

	// Check if route uses TLS
	tlsCmd := exec.Command("oc", "get", "route", serviceName,
		"-n", namespace,
		"-o", "jsonpath={.spec.tls.termination}",
		"--ignore-not-found")

	tlsOutput, _ := tlsCmd.CombinedOutput() //nolint:errcheck
	tlsTermination := strings.TrimSpace(string(tlsOutput))

	// Determine scheme
	scheme := "http"
	if tlsTermination != "" {
		scheme = "https"
	}

	return fmt.Sprintf("%s://%s", scheme, host)
}

// ClearRouteCache clears the route cache (useful for testing)
func ClearRouteCache() {
	routeCache.mu.Lock()
	defer routeCache.mu.Unlock()
	routeCache.routes = make(map[string]string)
}

// WaitForServiceReady waits for a service to become accessible
// This is useful after a build step completes, before running HTTP tests
func WaitForServiceReady(serviceName, namespace string, timeout time.Duration) error {
	logger.Waiting(fmt.Sprintf("Waiting for service %s/%s to be ready...", namespace, serviceName))

	deadline := time.Now().Add(timeout)
	attempt := 0

	for time.Now().Before(deadline) {
		attempt++

		// Check if service exists
		cmd := exec.Command("oc", "get", "service", serviceName,
			"-n", namespace,
			"--ignore-not-found",
			"-o", "jsonpath={.metadata.name}")

		output, err := cmd.CombinedOutput()
		if err == nil && strings.TrimSpace(string(output)) == serviceName {
			logger.Success(fmt.Sprintf("Service is ready after %d check(s)", attempt))
			return nil
		}

		time.Sleep(2 * time.Second)
	}

	return fmt.Errorf("service %s/%s did not become ready within %v", namespace, serviceName, timeout)
}

// GetServicePort retrieves the primary port for a service
func GetServicePort(serviceName, namespace string) (string, error) {
	cmd := exec.Command("oc", "get", "service", serviceName,
		"-n", namespace,
		"-o", "jsonpath={.spec.ports[0].port}")

	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("failed to get service port: %w (output: %s)", err, string(output))
	}

	port := strings.TrimSpace(string(output))
	if port == "" {
		return "", fmt.Errorf("service has no ports defined")
	}

	return port, nil
}

// ConstructServiceURL builds a standard internal service URL
func ConstructServiceURL(serviceName, namespace, port, path string) string {
	if !strings.HasPrefix(path, "/") && path != "" {
		path = "/" + path
	}
	return fmt.Sprintf("http://%s.%s.svc.cluster.local:%s%s", serviceName, namespace, port, path)
}
