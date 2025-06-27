#!/bin/bash

# Run both Python and Node.js apps in development mode
# Usage: ./run.dev.sh [python|nodejs|all] [--detach]
set -e

APP=${1:-all}
DETACH=${2:-}

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

run_python() {
  docker rm -f python-app-dev 2>/dev/null || true
  print_status "Starting Python app (dev)..."
  local run_cmd="docker run"
  if [ "$DETACH" = "--detach" ]; then run_cmd="$run_cmd -d"; else run_cmd="$run_cmd -it"; fi
  $run_cmd --name python-app-dev -p 5000:5000 -e ENVIRONMENT=dev -e PORT=5000 --restart unless-stopped python-app:dev
  print_success "Python app (dev) running on http://localhost:5000/"
}

run_nodejs() {
  docker rm -f nodejs-app-dev 2>/dev/null || true
  print_status "Starting Node.js app (dev)..."
  local run_cmd="docker run"
  if [ "$DETACH" = "--detach" ]; then run_cmd="$run_cmd -d"; else run_cmd="$run_cmd -it"; fi
  $run_cmd --name nodejs-app-dev -p 3000:3000 -e ENVIRONMENT=dev -e PORT=3000 --restart unless-stopped nodejs-app:dev
  print_success "Node.js app (dev) running on http://localhost:3000/"
}

main() {
  case $APP in
    python)
      run_python
      ;;
    nodejs)
      run_nodejs
      ;;
    all)
      run_python
      run_nodejs
      ;;
    *)
      echo "Usage: $0 [python|nodejs|all] [--detach]"; exit 1
      ;;
  esac
}

main $@ 