#!/usr/bin/env bash
set -eu -o pipefail

# Developer-friendly test runner for quickstarters
# This script provides a simple interface to run quickstarter tests
# with automatic environment detection and helpful output

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR="${SCRIPT_DIR}/.."

# Default values
QUICKSTARTER="${1:-be-python-flask}"
PROJECT="${2:-devtest}"
PARALLEL="${3:-1}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

function print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

function print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

function print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

function print_error() {
    echo -e "${RED}✗ $1${NC}"
}

function check_prerequisites() {
    local missing_tools=()

    # Check for required tools
    if ! command -v oc &> /dev/null; then
        missing_tools+=("oc (OpenShift CLI)")
    fi

    if ! command -v go &> /dev/null; then
        missing_tools+=("go")
    fi

    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi

    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        echo ""
        echo "Please install the missing tools and try again."
        exit 1
    fi

    # Check if logged into OpenShift
    if ! oc whoami &> /dev/null; then
        print_error "Not logged into OpenShift"
        echo "Please run 'oc login' first."
        exit 1
    fi

    print_success "All prerequisites met"
}

function detect_environment() {
    print_header "Environment Detection"

    # Check if running in cluster
    if [ -n "${KUBERNETES_SERVICE_HOST:-}" ]; then
        print_info "Execution environment: Inside Kubernetes/OpenShift cluster"
        print_info "Network strategy: Service DNS (no port-forwards needed)"
    else
        print_info "Execution environment: Local development machine"
        print_info "Network strategy: Automatic (routes > port-forward > service DNS)"
        print_warning "Port-forwards will be set up automatically as needed"
    fi

    # Show current OpenShift context
    current_user=$(oc whoami 2>/dev/null || echo "unknown")
    current_server=$(oc whoami --show-server 2>/dev/null || echo "unknown")
    
    print_info "OpenShift user: $current_user"
    print_info "OpenShift server: $current_server"
}

function show_test_info() {
    print_header "Test Configuration"
    
    echo "  Quickstarter: $QUICKSTARTER"
    echo "  Project: $PROJECT"
    echo "  Parallelism: $PARALLEL"
    echo ""
}

function run_tests() {
    print_header "Running Tests"
    
    cd "$ODS_CORE_DIR/tests"
    
    # Run the quickstarter test
    print_info "Executing: make test-quickstarter QS=$QUICKSTARTER PROJECT=$PROJECT PARALLEL=$PARALLEL"
    echo ""
    
    if make test-quickstarter QS="$QUICKSTARTER" PROJECT="$PROJECT" PARALLEL="$PARALLEL"; then
        print_success "Tests passed!"
        return 0
    else
        print_error "Tests failed!"
        return 1
    fi
}

function show_usage() {
    cat << EOF
Usage: $0 [QUICKSTARTER] [PROJECT] [PARALLEL]

Developer-friendly test runner for ODS quickstarters.

Arguments:
  QUICKSTARTER  Quickstarter to test (default: be-python-flask)
                Examples:
                  - be-python-flask          (single quickstarter)
                  - ods-quickstarters/...    (all quickstarters)
                  - be-golang-plain          (another single quickstarter)
  
  PROJECT       OpenShift project name for testing (default: devtest)
  
  PARALLEL      Number of tests to run in parallel (default: 1)

Examples:
  # Test be-python-flask in 'devtest' project
  $0

  # Test specific quickstarter in custom project
  $0 be-golang-plain myproject

  # Test all quickstarters with parallelism
  $0 ods-quickstarters/... testproj 3

Features:
  ✓ Automatic environment detection (in-cluster vs local)
  ✓ Smart URL resolution (routes > port-forward > service DNS)
  ✓ Automatic port-forward setup for local development
  ✓ Automatic cleanup on exit or interrupt (Ctrl+C)
  ✓ Clear, colorful output

Network Access:
  When running locally, the test framework will automatically:
  1. Try to use OpenShift routes if they exist (fastest, most reliable)
  2. Set up port-forwards for services without routes
  3. Fall back to service DNS if running inside the cluster

  You don't need to manually set up port-forwards - it's all automatic!

EOF
}

# Main execution
main() {
    # Show usage if help requested
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        show_usage
        exit 0
    fi

    print_header "ODS Quickstarter Test Runner"
    
    check_prerequisites
    detect_environment
    show_test_info
    
    if run_tests; then
        print_header "Test Summary"
        print_success "All tests completed successfully!"
        echo ""
        exit 0
    else
        print_header "Test Summary"
        print_error "Some tests failed. Check the output above for details."
        exit 1
    fi
}

main "$@"
