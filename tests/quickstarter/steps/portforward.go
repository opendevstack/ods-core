package steps

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"sync"
	"syscall"
	"time"

	"github.com/opendevstack/ods-core/tests/quickstarter/logger"
)

// PortForwardManager manages the lifecycle of port-forwards for local development
type PortForwardManager struct {
	forwards      map[string]*PortForward
	mu            sync.Mutex
	nextLocalPort int
}

// PortForward represents a single port-forward session
type PortForward struct {
	ServiceName string
	Namespace   string
	RemotePort  string
	LocalPort   int
	Cmd         *exec.Cmd
	Started     time.Time
}

var (
	globalPortForwardManager = &PortForwardManager{
		forwards:      make(map[string]*PortForward),
		nextLocalPort: 8000,
	}
)

// EnsurePortForward ensures a port-forward exists for the given service
// Returns the local port number that can be used to access the service
func EnsurePortForward(serviceName, namespace, remotePort string) (int, error) {
	return globalPortForwardManager.ensurePortForward(serviceName, namespace, remotePort)
}

// CleanupAllPortForwards terminates all active port-forwards
func CleanupAllPortForwards() {
	globalPortForwardManager.cleanupAll()
}

// ensurePortForward is the internal implementation
func (m *PortForwardManager) ensurePortForward(serviceName, namespace, remotePort string) (int, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	key := fmt.Sprintf("%s/%s:%s", namespace, serviceName, remotePort)

	// Check if port-forward already exists and is healthy
	if pf, exists := m.forwards[key]; exists {
		if m.isHealthy(pf) {
			logger.Success(fmt.Sprintf("Reusing existing port-forward: localhost:%d -> %s/%s:%s",
				pf.LocalPort, namespace, serviceName, remotePort))
			return pf.LocalPort, nil
		}
		// Port-forward exists but is unhealthy, clean it up
		logger.Warn("Existing port-forward is unhealthy, recreating...")
		m.cleanup(pf)
		delete(m.forwards, key)
	}

	// Start new port-forward
	localPort := m.nextLocalPort
	m.nextLocalPort++

	pf, err := m.startPortForward(serviceName, namespace, remotePort, localPort)
	if err != nil {
		return 0, fmt.Errorf("failed to start port-forward: %w", err)
	}

	m.forwards[key] = pf
	logger.Success(fmt.Sprintf("Port-forward established: localhost:%d -> %s/%s:%s",
		localPort, namespace, serviceName, remotePort))

	return localPort, nil
}

// startPortForward starts a new port-forward process
func (m *PortForwardManager) startPortForward(serviceName, namespace, remotePort string, startPort int) (*PortForward, error) {
	// Try up to 10 different ports in case of conflicts
	var lastErr error
	currentPort := startPort

	for attempt := 1; attempt <= 10; attempt++ {
		if attempt > 1 {
			// Try next port
			currentPort = startPort + attempt - 1
			logger.Warn(fmt.Sprintf("Port %d in use, trying port %d...", currentPort-1, currentPort))
		}

		pf, err := m.startPortForwardAttempt(serviceName, namespace, remotePort, currentPort)
		if err == nil {
			// Success! Update nextLocalPort to avoid this port in future
			if currentPort >= m.nextLocalPort {
				m.nextLocalPort = currentPort + 1
			}
			logger.Success(fmt.Sprintf("Port-forward established: localhost:%d -> %s/%s:%s",
				currentPort, namespace, serviceName, remotePort))
			return pf, nil
		}
		lastErr = err

		// If error is not about port already in use, fail immediately
		// Don't retry with same port as this causes duplicate port-forwards
		if !isPortInUseError(err) {
			return nil, fmt.Errorf("failed to start port-forward: %w", err)
		}

		// Port is in use, loop will try next port
	}

	return nil, fmt.Errorf("failed to find available port after trying %d-%d: %w", startPort, startPort+9, lastErr)
}

// startPortForwardAttempt performs a single attempt to start port-forward
func (m *PortForwardManager) startPortForwardAttempt(serviceName, namespace, remotePort string, localPort int) (*PortForward, error) {
	portMapping := fmt.Sprintf("%d:%s", localPort, remotePort)
	serviceRef := fmt.Sprintf("svc/%s", serviceName)

	cmd := exec.Command("oc", "port-forward",
		serviceRef,
		portMapping,
		"-n", namespace)

	// Capture both stdout and stderr to detect errors
	// oc port-forward writes "Forwarding from..." to stdout
	// and errors to stderr
	var stdoutBuf, stderrBuf bytes.Buffer
	cmd.Stdout = &stdoutBuf
	cmd.Stderr = &stderrBuf

	// Start the process
	if err := cmd.Start(); err != nil {
		return nil, fmt.Errorf("failed to start oc port-forward: %w", err)
	}

	pf := &PortForward{
		ServiceName: serviceName,
		Namespace:   namespace,
		RemotePort:  remotePort,
		LocalPort:   localPort,
		Cmd:         cmd,
		Started:     time.Now(),
	}

	// Wait a bit for port-forward to establish
	time.Sleep(2 * time.Second)

	stderrOutput := stderrBuf.String()
	stdoutOutput := stdoutBuf.String()

	// Check if process is still running
	if m.isHealthy(pf) {
		if stdoutOutput != "" {
			fmt.Print(stdoutOutput)
		}
		return pf, nil
	}

	// Process not healthy — check if stderr shows an error
	if stderrOutput != "" {
		fmt.Fprintf(os.Stderr, "%s", stderrOutput)
		if pf.Cmd.Process != nil {
			pf.Cmd.Process.Kill()
		}
		return nil, fmt.Errorf("port-forward failed: %s", stderrOutput)
	}

	// Sometimes oc port-forward continues running in background even if we can't track it.
	// If stdout indicates it started, treat as success.
	if strings.Contains(stdoutOutput, "Forwarding from") {
		fmt.Print(stdoutOutput)
		return pf, nil
	}

	return nil, fmt.Errorf("port-forward process died immediately after start")
}

// isHealthy checks if a port-forward is still running
func (m *PortForwardManager) isHealthy(pf *PortForward) bool {
	if pf.Cmd == nil || pf.Cmd.Process == nil {
		return false
	}

	// Check if process is still running
	// On Unix, sending signal 0 checks if process exists without actually sending a signal
	if err := pf.Cmd.Process.Signal(syscall.Signal(0)); err != nil {
		return false
	}

	return true
}

// cleanup terminates a single port-forward
func (m *PortForwardManager) cleanup(pf *PortForward) {
	if pf.Cmd != nil && pf.Cmd.Process != nil {
		// Try graceful termination first
		pf.Cmd.Process.Signal(os.Interrupt)

		// Wait briefly for graceful shutdown
		done := make(chan bool, 1)
		go func() {
			pf.Cmd.Wait()
			done <- true
		}()

		select {
		case <-done:
			// Process terminated gracefully
		case <-time.After(2 * time.Second):
			// Force kill if not terminated
			pf.Cmd.Process.Kill()
		}
	}
}

// cleanupAll terminates all active port-forwards
func (m *PortForwardManager) cleanupAll() {
	m.mu.Lock()
	defer m.mu.Unlock()

	if len(m.forwards) == 0 {
		return
	}

	logger.SubSection("Cleaning up port-forwards")

	for key, pf := range m.forwards {
		logger.Running(fmt.Sprintf("Terminating port-forward: localhost:%d -> %s/%s:%s",
			pf.LocalPort, pf.Namespace, pf.ServiceName, pf.RemotePort))
		m.cleanup(pf)
		delete(m.forwards, key)
	}

	logger.Success("All port-forwards cleaned up")
}

// GetActivePortForwards returns information about active port-forwards (for debugging)
func GetActivePortForwards() []string {
	globalPortForwardManager.mu.Lock()
	defer globalPortForwardManager.mu.Unlock()

	var result []string
	for _, pf := range globalPortForwardManager.forwards {
		status := "healthy"
		if !globalPortForwardManager.isHealthy(pf) {
			status = "unhealthy"
		}
		result = append(result, fmt.Sprintf("localhost:%d -> %s/%s:%s (%s, started %s)",
			pf.LocalPort, pf.Namespace, pf.ServiceName, pf.RemotePort, status,
			pf.Started.Format("15:04:05")))
	}
	return result
}

// isPortInUseError checks if an error is due to port already being in use
func isPortInUseError(err error) bool {
	if err == nil {
		return false
	}
	errMsg := err.Error()
	return contains(errMsg, "address already in use") ||
		contains(errMsg, "bind: address already in use") ||
		contains(errMsg, "unable to listen on port")
}

// contains is a simple string contains helper
func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(substr) == 0 ||
		(len(s) > 0 && len(substr) > 0 && findSubstring(s, substr)))
}

// findSubstring checks if substr exists in s
func findSubstring(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
