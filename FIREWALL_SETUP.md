# Firewall Configuration Guide

This guide explains how to configure your firewall to expose port 9999 (where the translator app runs) to the public internet.

## Understanding the Setup

- **Container Port:** 80 (internal, inside Docker container)
- **Host Port:** 9999 (on your Ubuntu server)
- **Public Access:** Port 9999 should be accessible from the internet

## Step 1: Configure UFW (Uncomplicated Firewall)

### Check Current Status
```bash
sudo ufw status verbose
```

### Allow Port 9999
```bash
# Allow incoming connections on port 9999
sudo ufw allow 9999/tcp

# Add a comment for reference
sudo ufw allow 9999/tcp comment 'Translator App'

# Enable UFW if not already enabled
sudo ufw enable
```

### Verify
```bash
sudo ufw status numbered
```

You should see:
```
9999/tcp                   ALLOW       Translator App
```

## Step 2: Configure iptables (Alternative to UFW)

If you're not using UFW, configure iptables directly:

```bash
# Allow incoming TCP connections on port 9999
sudo iptables -A INPUT -p tcp --dport 9999 -j ACCEPT

# Save rules (Ubuntu/Debian)
sudo netfilter-persistent save

# Or for CentOS/RHEL
sudo service iptables save
```

## Step 3: Router/Network Configuration

If your server is behind a router or NAT:

### Port Forwarding Setup
1. **Access Router Admin Panel** (usually 192.168.1.1 or 192.168.0.1)
2. **Navigate to Port Forwarding/Virtual Server**
3. **Add Rule:**
   - **External Port:** 80 (or 9999, or 443 for HTTPS)
   - **Internal IP:** Your server's local IP (e.g., 192.168.1.100)
   - **Internal Port:** 9999
   - **Protocol:** TCP

### Example Router Configuration
```
Service Name: Translator App
External Port: 80
Internal IP: 192.168.1.100
Internal Port: 9999
Protocol: TCP
```

## Step 4: Test Connectivity

### Test Locally
```bash
# From the server itself
curl http://localhost:9999/health

# Should return: healthy
```

### Test from External Network
```bash
# From another machine
curl http://your-server-public-ip:9999/health

# Or use a browser
# http://your-server-public-ip:9999
```

### Test with Domain
```bash
# If DNS is configured
curl http://translator-ai.dailystar.press:9999/health
```

## Step 5: Using Reverse Proxy (Optional)

If you want to access the app on standard ports (80/443) without changing the Docker port:

### Install Nginx on Host
```bash
sudo apt install -y nginx
```

### Configure Nginx
Create `/etc/nginx/sites-available/translator-ai.dailystar.press`:

```nginx
server {
    listen 80;
    server_name translator-ai.dailystar.press;

    location / {
        proxy_pass http://127.0.0.1:9999;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support (if needed)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### Enable and Test
```bash
sudo ln -s /etc/nginx/sites-available/translator-ai.dailystar.press /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Now access via: `http://translator-ai.dailystar.press` (port 80)

## Troubleshooting

### Port Not Accessible
1. **Check if port is listening:**
   ```bash
   sudo netstat -tulpn | grep 9999
   # or
   sudo ss -tulpn | grep 9999
   ```

2. **Check firewall rules:**
   ```bash
   sudo ufw status
   # or
   sudo iptables -L -n -v | grep 9999
   ```

3. **Check Docker container:**
   ```bash
   docker ps
   docker logs translator-ai-dailystar
   ```

4. **Test from server:**
   ```bash
   curl -v http://localhost:9999
   ```

### Firewall Blocking
```bash
# Temporarily disable firewall to test (NOT recommended for production)
sudo ufw disable

# Test access, then re-enable
sudo ufw enable
```

### Port Already in Use
```bash
# Check what's using port 9999
sudo lsof -i :9999
# or
sudo fuser 9999/tcp

# Kill the process if needed (be careful!)
sudo kill -9 <PID>
```

## Security Considerations

1. **Limit Access by IP (Optional):**
   ```bash
   # Only allow specific IPs
   sudo ufw allow from 1.2.3.4 to any port 9999
   ```

2. **Use Fail2Ban:**
   ```bash
   sudo apt install fail2ban
   # Configure to protect against brute force
   ```

3. **Regular Updates:**
   ```bash
   sudo apt update && sudo apt upgrade
   ```

## Quick Reference

```bash
# Allow port
sudo ufw allow 9999/tcp

# Remove rule
sudo ufw delete allow 9999/tcp

# Check status
sudo ufw status

# View logs
sudo tail -f /var/log/ufw.log
```

