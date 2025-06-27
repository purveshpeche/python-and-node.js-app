#!/bin/bash

# Build script for Python and Node.js applications
# Usage: ./build.sh [python|nodejs|all] [dev|prod]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
APP=${1:-all}
ENV=${2:-dev}

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

# Function to build Python app
build_python() {
    local env=$1
    print_status "Building Python application for $env environment..."
    
    cd python-app
    
    if [ "$env" = "prod" ]; then
        docker build --target production -t python-app:latest -t python-app:prod .
        print_success "Python app production image built successfully"
    else
        docker build --target development -t python-app:dev .
        print_success "Python app development image built successfully"
    fi
    
    cd ..
}

# Function to build Node.js app
build_nodejs() {
    local env=$1
    print_status "Building Node.js application for $env environment..."
    
    cd nodejs-app
    
    if [ "$env" = "prod" ]; then
        docker build --target production -t nodejs-app:latest -t nodejs-app:prod .
        print_success "Node.js app production image built successfully"
    else
        docker build --target development -t nodejs-app:dev .
        print_success "Node.js app development image built successfully"
    fi
    
    cd ..
}

# Main build logic
main() {
    print_status "Starting build process..."
    print_status "Application: $APP"
    print_status "Environment: $ENV"
    
    case $APP in
        "python")
            build_python $ENV
            ;;
        "nodejs")
            build_nodejs $ENV
            ;;
        "all")
            build_python $ENV
            build_nodejs $ENV
            ;;
        *)
            print_error "Invalid application specified. Use: python, nodejs, or all"
            exit 1
            ;;
    esac
    
    print_success "Build process completed!"
}

# Run main function
main 