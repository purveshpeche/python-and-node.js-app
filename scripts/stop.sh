#!/bin/bash

# Stop script for Python and Node.js applications
# Usage: ./stop.sh [python|nodejs|all]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
APP=${1:-all}

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to stop and remove container
stop_container() {
    local container_name=$1
    if docker ps -q -f name="$container_name" | grep -q .; then
        print_status "Stopping container: $container_name"
        docker stop "$container_name"
        print_status "Removing container: $container_name"
        docker rm "$container_name"
        print_success "Container $container_name stopped and removed"
    else
        print_warning "Container $container_name is not running"
    fi
}

# Function to stop Python app
stop_python() {
    print_status "Stopping Python application..."
    stop_container "python-app-dev"
    stop_container "python-app-prod"
}

# Function to stop Node.js app
stop_nodejs() {
    print_status "Stopping Node.js application..."
    stop_container "nodejs-app-dev"
    stop_container "nodejs-app-prod"
}

# Function to stop all containers
stop_all() {
    print_status "Stopping all applications..."
    stop_python
    stop_nodejs
}

# Main stop logic
main() {
    print_status "Stopping applications..."
    print_status "Application: $APP"
    
    case $APP in
        "python")
            stop_python
            ;;
        "nodejs")
            stop_nodejs
            ;;
        "all")
            stop_all
            ;;
        *)
            print_error "Invalid application specified. Use: python, nodejs, or all"
            exit 1
            ;;
    esac
    
    print_success "Stop process completed!"
}

# Run main function
main 