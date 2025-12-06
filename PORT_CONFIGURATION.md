# Port Configuration Summary

## Current Setup

- **Docker Container Internal Port:** 80 (nginx inside container)
- **Host Server Port:** 9999 (mapped from container)
- **Public Access:** Port 9999 exposed through firewall

## Port Mapping

```
Internet → Firewall (Port 9999) → Ubuntu Server (Port 9999) → Docker Container (Port 80)
```

## Configuration Files

### docker-compose.yml
```yaml
ports:
  - "9999:80"  # Host:Container
```

### Firewall Rules
```bash
sudo ufw allow 9999/tcp
```

## Access URLs

- **Local (on server):** http://localhost:9999
- **Network (server IP):** http://192.168.x.x:9999
- **Public (domain/IP):** http://translator-ai.dailystar.press:9999
- **Health Check:** http://translator-ai.dailystar.press:9999/health

## Why Port 9999?

Port 9999 is used to avoid conflicts with other applications that may be using port 80 (like web servers, reverse proxies, or other Docker containers).

## Changing the Port

If you need to use a different port, update:

1. **docker-compose.yml:**
   ```yaml
   ports:
     - "YOUR_PORT:80"
   ```

2. **Firewall:**
   ```bash
   sudo ufw allow YOUR_PORT/tcp
   ```

3. **Update all documentation references**

## Reverse Proxy Option

If you want to access the app on standard port 80/443, set up an Nginx reverse proxy on the host that forwards to localhost:9999. See `DEPLOYMENT.md` section 6 for details.


