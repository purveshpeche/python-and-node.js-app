#!/bin/bash

# Build both Python and Node.js apps for development
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

print_status "Building Python app (development)..."
cd python-app

docker build --target development -t python-app:dev .
print_success "Python app (dev) built."
cd ..

print_status "Building Node.js app (development)..."
cd nodejs-app
docker build --target development -t nodejs-app:dev .
print_success "Node.js app (dev) built."
cd ..

print_success "Development images built successfully!" 