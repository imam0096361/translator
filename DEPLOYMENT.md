# Deployment Guide for Daily Star Style Translator

This guide explains how to deploy the translator app on an Ubuntu server using Docker.

## Prerequisites

- Ubuntu Server (20.04 or later)
- Docker installed
- Docker Compose installed
- Domain `translator-ai.dailystar.press` pointing to your server's IP

## Installation Steps

### 1. Install Docker and Docker Compose

```bash
# Update package index
sudo apt update

# Install Docker
sudo apt install -y docker.io docker-compose

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (optional, to run without sudo)
sudo usermod -aG docker $USER
```

### 2. Clone/Upload Project Files

Upload all project files to your server, for example:
```bash
# On your local machine, use scp or rsync
scp -r . user@your-server-ip:/opt/translator-app/
```

Or clone from git repository if available.

### 3. Set Environment Variables

Create a `.env` file in the project root:
```bash
cd /opt/translator-app
nano .env
```

Add your Gemini API key:
```
GEMINI_API_KEY=your_actual_api_key_here
```

**Important:** Get your API key from https://aistudio.google.com/apikey

### 4. Build and Run with Docker Compose

```bash
# Build and start the container
docker-compose up -d --build

# Check if container is running
docker-compose ps

# View logs
docker-compose logs -f
```

### 5. Configure Firewall (Port 9999)

The application runs on port 9999 to avoid conflicts with other services on port 80.

```bash
# Allow port 9999 through firewall
sudo ufw allow 9999/tcp

# If using UFW, enable it (if not already enabled)
sudo ufw enable

# Verify firewall status
sudo ufw status
```

**For iptables (if not using UFW):**
```bash
# Allow incoming connections on port 9999
sudo iptables -A INPUT -p tcp --dport 9999 -j ACCEPT

# Save iptables rules (Ubuntu)
sudo netfilter-persistent save
```

**Port Forwarding (if behind NAT/router):**
If your server is behind a router/NAT, configure port forwarding:
- External/Public IP Port: 80 (or 443 for HTTPS)
- Internal/Private IP: Your server's local IP
- Internal Port: 9999

### 6. Configure Nginx Reverse Proxy (Optional but Recommended)

If you want to use a reverse proxy with SSL on port 80/443, install nginx on the host:

```bash
sudo apt install -y nginx certbot python3-certbot-nginx
```

Create nginx configuration at `/etc/nginx/sites-available/translator-ai.dailystar.press`:

```nginx
server {
    listen 80;
    server_name translator-ai.dailystar.press;

    location / {
        proxy_pass http://localhost:9999;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/translator-ai.dailystar.press /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 7. Set Up SSL Certificate (Recommended)

```bash
sudo certbot --nginx -d translator-ai.dailystar.press
```

Follow the prompts to complete SSL setup.

## Management Commands

### View Logs
```bash
docker-compose logs -f translator-app
```

### Restart Container
```bash
docker-compose restart translator-app
```

### Stop Container
```bash
docker-compose down
```

### Update Application
```bash
# Pull latest code
git pull  # or upload new files

# Rebuild and restart
docker-compose up -d --build
```

### Check Container Status
```bash
docker-compose ps
docker stats translator-ai-dailystar
```

## Troubleshooting

### Container won't start
- Check logs: `docker-compose logs translator-app`
- Verify `.env` file exists and has `GEMINI_API_KEY`
- Check if port 9999 is available: `sudo netstat -tulpn | grep :9999`
- Verify port 9999 is not in use: `sudo lsof -i :9999`

### API Key Issues
- Ensure `GEMINI_API_KEY` is set in `.env` file
- Rebuild container after changing `.env`: `docker-compose up -d --build`

### Domain Not Resolving
- Verify DNS A record points to server IP
- Check firewall allows port 9999: `sudo ufw allow 9999/tcp`
- Test local access: `curl http://localhost:9999`
- Test from external: `curl http://your-server-ip:9999`

### SSL Certificate Issues
- Ensure domain DNS is properly configured
- Check nginx configuration: `sudo nginx -t`
- Review certbot logs: `sudo certbot certificates`

## Security Notes

1. **API Key Security**: The API key is embedded in the client-side bundle. Consider implementing a backend proxy if you need to keep the key secret.

2. **Firewall**: Configure UFW or iptables to only allow necessary ports:
   ```bash
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 9999/tcp  # Translator App (or 80/443 if using reverse proxy)
   sudo ufw allow 80/tcp    # HTTP (if using reverse proxy)
   sudo ufw allow 443/tcp   # HTTPS (if using reverse proxy)
   sudo ufw enable
   ```

3. **Regular Updates**: Keep Docker images updated:
   ```bash
   docker-compose pull
   docker-compose up -d --build
   ```

## Production Considerations

- Set up monitoring (e.g., Prometheus, Grafana)
- Configure log rotation
- Set up automated backups
- Consider using a process manager like PM2 if running multiple services
- Implement rate limiting if needed

## Support

For issues or questions, check the application logs and Docker container status first.

