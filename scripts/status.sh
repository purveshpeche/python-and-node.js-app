#!/bin/bash

# Status script for Python and Node.js applications
# Usage: ./status.sh [python|nodejs|all]

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

# Function to check container status
check_container() {
    local container_name=$1
    local port=$2
    local health_endpoint=$3
    
    echo "----------------------------------------"
    echo "Container: $container_name"
    echo "----------------------------------------"
    
    # Check if container is running
    if docker ps -q -f name="$container_name" | grep -q .; then
        print_success "Status: Running"
        
        # Get container info
        local container_info=$(docker inspect "$container_name" 2>/dev/null)
        if [ $? -eq 0 ]; then
            local image=$(echo "$container_info" | jq -r '.[0].Config.Image' 2>/dev/null || echo "Unknown")
            local created=$(echo "$container_info" | jq -r '.[0].Created' 2>/dev/null || echo "Unknown")
            local state=$(echo "$container_info" | jq -r '.[0].State.Status' 2>/dev/null || echo "Unknown")
            
            echo "Image: $image"
            echo "Created: $created"
            echo "State: $state"
        fi
        
        # Check health endpoint
        if [ -n "$health_endpoint" ]; then
            print_status "Checking health endpoint..."
            if curl -s -f "http://localhost:$port$health_endpoint" > /dev/null 2>&1; then
                print_success "Health check: OK"
            else
                print_warning "Health check: Failed"
            fi
        fi
        
        # Show logs (last 5 lines)
        print_status "Recent logs:"
        docker logs --tail 5 "$container_name" 2>/dev/null || echo "No logs available"
        
    else
        print_error "Status: Not running"
        
        # Check if container exists but is stopped
        if docker ps -aq -f name="$container_name" | grep -q .; then
            print_warning "Container exists but is stopped"
        else
            print_warning "Container does not exist"
        fi
    fi
    
    echo ""
}

# Function to check Python app status
check_python() {
    print_status "Checking Python application status..."
    check_container "python-app-dev" "5000" "/health"
    check_container "python-app-prod" "5000" "/health"
}

# Function to check Node.js app status
check_nodejs() {
    print_status "Checking Node.js application status..."
    check_container "nodejs-app-dev" "3000" "/health"
    check_container "nodejs-app-prod" "3000" "/health"
}

# Function to check all containers
check_all() {
    print_status "Checking all applications status..."
    check_python
    check_nodejs
}

# Function to show system resources
show_resources() {
    echo "========================================"
    echo "SYSTEM RESOURCES"
    echo "========================================"
    
    # Docker info
    print_status "Docker containers:"
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker not available"
    
    echo ""
    
    # Port usage
    print_status "Port usage:"
    netstat -tlnp 2>/dev/null | grep -E ":(3000|5000)" || echo "No applications using ports 3000 or 5000"
    
    echo ""
    
    # Disk usage
    print_status "Disk usage:"
    df -h . | head -2
}

# Main status logic
main() {
    print_status "Checking application status..."
    print_status "Application: $APP"
    echo ""
    
    case $APP in
        "python")
            check_python
            ;;
        "nodejs")
            check_nodejs
            ;;
        "all")
            check_all
            ;;
        *)
            print_error "Invalid application specified. Use: python, nodejs, or all"
            exit 1
            ;;
    esac
    
    show_resources
}

# Run main function
main 