#!/bin/bash

# Cleanup script for Python and Node.js applications
# Usage: ./cleanup.sh [containers|images|volumes|all] [--force]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TARGET=${1:-all}
FORCE=${2:-}

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

# Function to confirm action
confirm_action() {
    local message=$1
    if [ "$FORCE" != "--force" ]; then
        echo -n "$message (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_warning "Operation cancelled"
            exit 0
        fi
    fi
}

# Function to cleanup containers
cleanup_containers() {
    print_status "Cleaning up containers..."
    
    # Stop and remove running containers
    local containers=(
        "python-app-dev"
        "python-app-prod"
        "nodejs-app-dev"
        "nodejs-app-prod"
    )
    
    for container in "${containers[@]}"; do
        if docker ps -q -f name="$container" | grep -q .; then
            print_status "Stopping container: $container"
            docker stop "$container" || true
        fi
        
        if docker ps -aq -f name="$container" | grep -q .; then
            print_status "Removing container: $container"
            docker rm "$container" || true
        fi
    done
    
    # Remove any other containers with our app names
    docker ps -aq --filter "name=python-app" --filter "name=nodejs-app" | xargs -r docker rm -f || true
    
    print_success "Containers cleaned up"
}

# Function to cleanup images
cleanup_images() {
    print_status "Cleaning up images..."
    
    # Remove our application images
    local images=(
        "python-app:dev"
        "python-app:prod"
        "python-app:latest"
        "nodejs-app:dev"
        "nodejs-app:prod"
        "nodejs-app:latest"
    )
    
    for image in "${images[@]}"; do
        if docker images -q "$image" | grep -q .; then
            print_status "Removing image: $image"
            docker rmi "$image" || true
        fi
    done
    
    # Remove dangling images
    print_status "Removing dangling images..."
    docker image prune -f || true
    
    print_success "Images cleaned up"
}

# Function to cleanup volumes
cleanup_volumes() {
    print_status "Cleaning up volumes..."
    
    # Remove volumes associated with our containers
    docker volume ls -q --filter "name=python-app" --filter "name=nodejs-app" | xargs -r docker volume rm || true
    
    # Remove unused volumes
    print_status "Removing unused volumes..."
    docker volume prune -f || true
    
    print_success "Volumes cleaned up"
}

# Function to cleanup networks
cleanup_networks() {
    print_status "Cleaning up networks..."
    
    # Remove unused networks
    docker network prune -f || true
    
    print_success "Networks cleaned up"
}

# Function to cleanup all
cleanup_all() {
    print_warning "This will remove ALL containers, images, volumes, and networks!"
    confirm_action "Are you sure you want to proceed?"
    
    print_status "Performing full cleanup..."
    
    # Stop all running containers
    print_status "Stopping all running containers..."
    docker stop $(docker ps -q) 2>/dev/null || true
    
    # Remove all containers
    print_status "Removing all containers..."
    docker rm $(docker ps -aq) 2>/dev/null || true
    
    # Remove all images
    print_status "Removing all images..."
    docker rmi $(docker images -q) 2>/dev/null || true
    
    # Remove all volumes
    print_status "Removing all volumes..."
    docker volume rm $(docker volume ls -q) 2>/dev/null || true
    
    # Remove all networks
    print_status "Removing all networks..."
    docker network rm $(docker network ls -q) 2>/dev/null || true
    
    # System prune
    print_status "Performing system prune..."
    docker system prune -af --volumes || true
    
    print_success "Full cleanup completed"
}

# Function to show cleanup preview
show_preview() {
    echo "========================================"
    echo "CLEANUP PREVIEW"
    echo "========================================"
    
    case $TARGET in
        "containers")
            echo "Containers to be removed:"
            docker ps -a --filter "name=python-app" --filter "name=nodejs-app" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" 2>/dev/null || echo "No containers found"
            ;;
        "images")
            echo "Images to be removed:"
            docker images --filter "reference=python-app*" --filter "reference=nodejs-app*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null || echo "No images found"
            ;;
        "volumes")
            echo "Volumes to be removed:"
            docker volume ls --filter "name=python-app" --filter "name=nodejs-app" 2>/dev/null || echo "No volumes found"
            ;;
        "all")
            echo "All Docker resources will be removed!"
            echo "Running containers: $(docker ps -q | wc -l)"
            echo "All containers: $(docker ps -aq | wc -l)"
            echo "Images: $(docker images -q | wc -l)"
            echo "Volumes: $(docker volume ls -q | wc -l)"
            echo "Networks: $(docker network ls -q | wc -l)"
            ;;
    esac
    echo ""
}

# Main cleanup logic
main() {
    print_status "Starting cleanup process..."
    print_status "Target: $TARGET"
    print_status "Force mode: $([ "$FORCE" = "--force" ] && echo "Yes" || echo "No")"
    echo ""
    
    # Show preview
    show_preview
    
    case $TARGET in
        "containers")
            confirm_action "Do you want to remove the containers?"
            cleanup_containers
            ;;
        "images")
            confirm_action "Do you want to remove the images?"
            cleanup_images
            ;;
        "volumes")
            confirm_action "Do you want to remove the volumes?"
            cleanup_volumes
            ;;
        "all")
            cleanup_all
            ;;
        *)
            print_error "Invalid target specified. Use: containers, images, volumes, or all"
            exit 1
            ;;
    esac
    
    print_success "Cleanup process completed!"
}

# Run main function
main 