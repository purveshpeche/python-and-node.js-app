#!/bin/bash

# Run script for Python and Node.js applications
# Usage: ./run.sh [python|nodejs|all] [dev|prod] [--detach]

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
DETACH=${3:-}

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

# Function to stop existing containers
stop_container() {
    local container_name=$1
    if docker ps -q -f name="$container_name" | grep -q .; then
        print_status "Stopping existing container: $container_name"
        docker stop "$container_name" || true
        docker rm "$container_name" || true
    fi
}

# Function to run Python app
run_python() {
    local env=$1
    local container_name="python-app-$env"
    
    stop_container "$container_name"
    
    print_status "Starting Python application ($env environment)..."
    
    local image_tag="python-app:dev"
    if [ "$env" = "prod" ]; then
        image_tag="python-app:prod"
    fi
    
    local run_cmd="docker run"
    if [ "$DETACH" = "--detach" ]; then
        run_cmd="$run_cmd -d"
    else
        run_cmd="$run_cmd -it"
    fi
    
    $run_cmd \
        --name "$container_name" \
        -p 5000:5000 \
        -e ENVIRONMENT="$env" \
        -e PORT=5000 \
        --restart unless-stopped \
        "$image_tag"
    
    print_success "Python app started on http://localhost:5000"
}

# Function to run Node.js app
run_nodejs() {
    local env=$1
    local container_name="nodejs-app-$env"
    
    stop_container "$container_name"
    
    print_status "Starting Node.js application ($env environment)..."
    
    local image_tag="nodejs-app:dev"
    if [ "$env" = "prod" ]; then
        image_tag="nodejs-app:prod"
    fi
    
    local run_cmd="docker run"
    if [ "$DETACH" = "--detach" ]; then
        run_cmd="$run_cmd -d"
    else
        run_cmd="$run_cmd -it"
    fi
    
    $run_cmd \
        --name "$container_name" \
        -p 3000:3000 \
        -e ENVIRONMENT="$env" \
        -e PORT=3000 \
        --restart unless-stopped \
        "$image_tag"
    
    print_success "Node.js app started on http://localhost:3000"
}

# Function to check if images exist
check_image() {
    local image_name=$1
    if ! docker images | grep -q "$image_name"; then
        print_error "Image $image_name not found. Please build it first using ./build.sh"
        exit 1
    fi
}

# Main run logic
main() {
    print_status "Starting applications..."
    print_status "Application: $APP"
    print_status "Environment: $ENV"
    print_status "Detached mode: $([ "$DETACH" = "--detach" ] && echo "Yes" || echo "No")"
    
    case $APP in
        "python")
            check_image "python-app:$([ "$ENV" = "prod" ] && echo "prod" || echo "dev")"
            run_python $ENV
            ;;
        "nodejs")
            check_image "nodejs-app:$([ "$ENV" = "prod" ] && echo "prod" || echo "dev")"
            run_nodejs $ENV
            ;;
        "all")
            check_image "python-app:$([ "$ENV" = "prod" ] && echo "prod" || echo "dev")"
            check_image "nodejs-app:$([ "$ENV" = "prod" ] && echo "prod" || echo "dev")"
            run_python $ENV
            run_nodejs $ENV
            ;;
        *)
            print_error "Invalid application specified. Use: python, nodejs, or all"
            exit 1
            ;;
    esac
    
    print_success "Applications started successfully!"
    
    if [ "$DETACH" != "--detach" ]; then
        print_status "Press Ctrl+C to stop the applications"
        wait
    fi
}

# Run main function
main 