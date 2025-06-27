#!/bin/bash

# Build both Python and Node.js apps for production
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

print_status "Building Python app (production)..."
cd python-app

docker build --target production -t python-app:prod -t python-app:latest .
print_success "Python app (prod) built."
cd ..

print_status "Building Node.js app (production)..."
cd nodejs-app
docker build --target production -t nodejs-app:prod -t nodejs-app:latest .
print_success "Node.js app (prod) built."
cd ..

print_success "Production images built successfully!" 