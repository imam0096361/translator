# Quick Start Guide

## Prerequisites
- Docker and Docker Compose installed
- Gemini API key from https://aistudio.google.com/apikey

## Quick Deployment

1. **Create `.env` file:**
   ```bash
   echo "GEMINI_API_KEY=your_api_key_here" > .env
   ```

2. **Deploy:**
   ```bash
   # Make deploy script executable (first time only)
   chmod +x deploy.sh
   
   # Run deployment
   ./deploy.sh
   ```

   Or manually:
   ```bash
   docker-compose up -d --build
   ```

3. **Verify:**
   ```bash
   docker-compose ps
   docker-compose logs -f
   ```

## Access
- Application: http://translator-ai.dailystar.press:9999 (or http://your-server-ip:9999)
- Health check: http://translator-ai.dailystar.press:9999/health
- Local access: http://localhost:9999

**Note:** The app runs on port 9999 to avoid conflicts with other services. Configure firewall to allow port 9999.

## Common Commands

```bash
# View logs
docker-compose logs -f

# Restart
docker-compose restart

# Stop
docker-compose down

# Rebuild after code changes
docker-compose up -d --build
```

## Files Created
- `Dockerfile` - Multi-stage build (Node + Nginx)
- `docker-compose.yml` - Container orchestration
- `nginx.conf` - Web server configuration
- `.dockerignore` - Build exclusions
- `deploy.sh` - Deployment script
- `DEPLOYMENT.md` - Detailed deployment guide

