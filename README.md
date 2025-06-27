# Python and Node.js Applications - Docker Setup

This repository contains dockerized Python Flask and Node.js Express applications with comprehensive build, run, and management scripts.

## 📁 Project Structure

```
.
├── python-app/
│   ├── app.py              # Flask application
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile         # Python app Dockerfile
├── nodejs-app/
│   ├── app.js             # Express application
│   ├── package.json       # Node.js dependencies
│   └── Dockerfile         # Node.js app Dockerfile
├── scripts/
│   ├── build.dev.sh       # Build script (development)
│   ├── build.prod.sh      # Build script (production)
│   ├── build.sh           # (legacy, supports both)
│   ├── run.sh             # Run script
│   ├── stop.sh            # Stop script
│   ├── status.sh          # Status script
│   └── cleanup.sh         # Cleanup script
├── docker-compose.yml     # Development Docker Compose
├── docker-compose.prod.yml # Production Docker Compose
└── README.md              # This file
```

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Bash shell
- curl (for health checks)

### 1. Build Applications

#### For Development
```bash
./scripts/build.dev.sh
```

#### For Production
```bash
./scripts/build.prod.sh
```

### 2. Run Applications

```bash
# Run all applications in development mode
./scripts/run.sh

# Run specific application
./scripts/run.sh python dev
./scripts/run.sh nodejs prod

# Run in detached mode
./scripts/run.sh all dev --detach
```

### 3. Check Status

```bash
# Check status of all applications
./scripts/status.sh

# Check specific application
./scripts/status.sh python
./scripts/status.sh nodejs
```

### 4. Stop Applications

```bash
# Stop all applications
./scripts/stop.sh

# Stop specific application
./scripts/stop.sh python
./scripts/stop.sh nodejs
```

## 🐳 Docker Compose Usage

### Development Environment

```bash
# Start all services
docker-compose up

# Start in detached mode
docker-compose up -d

# Start specific service
docker-compose up python-app

# Rebuild and start
docker-compose up --build
```

### Production Environment

```bash
# Start production services
docker-compose -f docker-compose.prod.yml up -d

# Scale services
docker-compose -f docker-compose.prod.yml up -d --scale python-app=2 --scale nodejs-app=2
```

## 📋 Available Scripts

### build.dev.sh
Builds Docker images for both applications (development mode).

**Usage:**
```bash
./scripts/build.dev.sh
```

### build.prod.sh
Builds Docker images for both applications (production mode).

**Usage:**
```bash
./scripts/build.prod.sh
```

### run.sh
Runs containers with proper configuration.

**Usage:**
```bash
./scripts/run.sh [python|nodejs|all] [dev|prod] [--detach]
```

**Examples:**
```bash
./scripts/run.sh all dev              # Run both apps in development
./scripts/run.sh python prod --detach # Run Python app in production (detached)
./scripts/run.sh nodejs dev           # Run Node.js app in development
```

### stop.sh
Stops and removes running containers.

**Usage:**
```bash
./scripts/stop.sh [python|nodejs|all]
```

### status.sh
Shows status of containers, health checks, and system resources.

**Usage:**
```bash
./scripts/status.sh [python|nodejs|all]
```

### cleanup.sh
Removes containers, images, and volumes.

**Usage:**
```bash
./scripts/cleanup.sh [containers|images|volumes|all] [--force]
```

**Examples:**
```bash
./scripts/cleanup.sh containers        # Remove containers only
./scripts/cleanup.sh all --force       # Remove everything without confirmation
```

## 🌐 Application Endpoints

### Python Flask App (Port 5000)
- **Home:** `http://localhost:5000/`
- **Health:** `http://localhost:5000/health`
- **API Data:** `http://localhost:5000/api/data`
- **Status:** `http://localhost:5000/api/status`

### Node.js Express App (Port 3000)
- **Home:** `http://localhost:3000/`
- **Health:** `http://localhost:3000/health`
- **API Data:** `http://localhost:3000/api/data`
- **Status:** `http://localhost:3000/api/status`

## 🔧 Environment Variables

### Python App
- `ENVIRONMENT`: Set to `development` or `production`
- `PORT`: Application port (default: 5000)
- `FLASK_ENV`: Flask environment setting

### Node.js App
- `ENVIRONMENT`: Set to `development` or `production`
- `PORT`: Application port (default: 3000)
- `NODE_ENV`: Node.js environment setting

## 🏗️ Docker Images

### Development Images
- `python-app:dev` - Python Flask with development settings
- `nodejs-app:dev` - Node.js Express with development settings

### Production Images
- `python-app:prod` - Python Flask with Gunicorn
- `nodejs-app:prod` - Node.js Express optimized for production

## 🔍 Health Checks

Both applications include health check endpoints:
- Python: `GET /health`
- Node.js: `GET /health`

Docker health checks are configured to verify these endpoints every 30 seconds.

## 📊 Monitoring

### Container Logs
```bash
# View logs for specific container
docker logs python-app-dev
docker logs nodejs-app-dev

# Follow logs in real-time
docker logs -f python-app-dev
```

### Resource Usage
```bash
# Check container resource usage
docker stats

# Check specific container
docker stats python-app-dev nodejs-app-dev
```

## 🛠️ Development Workflow

1. **Start Development Environment:**
   ```bash
   ./scripts/build.dev.sh
   ./scripts/run.sh all dev
   ```

2. **Make Code Changes:**
   - Edit files in `python-app/` or `nodejs-app/`
   - Changes are reflected immediately due to volume mounts

3. **Rebuild After Dependency Changes:**
   ```bash
   ./scripts/build.dev.sh
   ./scripts/run.sh all dev
   ```

4. **Check Status:**
   ```bash
   ./scripts/status.sh
   ```

5. **Stop Development:**
   ```bash
   ./scripts/stop.sh
   ```

## 🚀 Production Deployment

1. **Build Production Images:**
   ```bash
   ./scripts/build.prod.sh
   ```

2. **Deploy with Docker Compose:**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

3. **Monitor Deployment:**
   ```bash
   ./scripts/status.sh
   docker-compose -f docker-compose.prod.yml logs -f
   ```

## 🧹 Cleanup

### Remove Everything
```bash
./scripts/cleanup.sh all --force
```

### Remove Specific Resources
```bash
./scripts/cleanup.sh containers  # Remove containers only
./scripts/cleanup.sh images      # Remove images only
./scripts/cleanup.sh volumes     # Remove volumes only
```

## 🔒 Security Features

- Non-root users in containers
- Minimal base images (Alpine for Node.js, slim for Python)
- Health checks for monitoring
- Resource limits in production
- Environment-specific configurations

## 📝 Troubleshooting

### Common Issues

1. **Port Already in Use:**
   ```bash
   # Check what's using the port
   sudo netstat -tlnp | grep :5000
   sudo netstat -tlnp | grep :3000
   
   # Stop conflicting containers
   ./scripts/stop.sh
   ```

2. **Build Failures:**
   ```bash
   # Clean and rebuild
   ./scripts/cleanup.sh images
   ./scripts/build.dev.sh
   ```

3. **Health Check Failures:**
   ```bash
   # Check container logs
   docker logs python-app-dev
   docker logs nodejs-app-dev
   
   # Check if services are responding
   curl http://localhost:5000/health
   curl http://localhost:3000/health
   ```

### Debug Mode

For debugging, you can run containers interactively:
```bash
# Run Python app in interactive mode
docker run -it --rm -p 5000:5000 python-app:dev bash

# Run Node.js app in interactive mode
docker run -it --rm -p 3000:3000 nodejs-app:dev sh
```

## 🛠️ Troubleshooting: Container Name Conflict & Not Accessible

### Problem: Can't Access App or Container Won't Start

**Symptoms:**
- You run the build and run scripts, but can't access `http://localhost:5000/` or `http://localhost:3000/`.
- You see errors like:
  - `Error response from daemon: Conflict. The container name "/python-app-dev" is already in use...`
  - The script says the image is missing, but `docker images` shows it exists.
- No containers are running (`docker ps -a` is empty or only shows exited containers).

### Cause
- Docker does not allow two containers with the same name.
- If a container with the same name exists (even if stopped/exited), you cannot start a new one with that name until you remove the old one.
- The run script tries to remove old containers, but if you run commands manually or something fails, you may need to clean up manually.

### Solution
1. **Check for existing containers:**
   ```bash
   docker ps -a
   ```
   If you see containers named `python-app-dev` or `nodejs-app-dev` in any state, remove them:
   ```bash
   docker rm python-app-dev
   docker rm nodejs-app-dev
   ```

2. **Start the containers again:**
   ```bash
   docker run --name python-app-dev -p 5000:5000 -e ENVIRONMENT=dev -e PORT=5000 --restart unless-stopped -d python-app:dev
   docker run --name nodejs-app-dev -p 3000:3000 -e ENVIRONMENT=dev -e PORT=3000 --restart unless-stopped -d nodejs-app:dev
   ```

3. **Check if they are running:**
   ```bash
   docker ps
   ```
   You should see both containers listed as "Up".

4. **Test in your browser or with curl:**
   ```bash
   curl http://localhost:5000/
   curl http://localhost:3000/
   ```

### Tip
- Always make sure to remove old containers before starting new ones with the same name.
- Use the provided `./scripts/stop.sh` and `./scripts/cleanup.sh` scripts to manage and clean up containers.

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with the provided scripts
5. Submit a pull request

