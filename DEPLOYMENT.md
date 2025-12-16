# Deployment Guide

This guide covers deploying the Rick and Morty MCP Server to a VDS/VPS server.

## Prerequisites

- Ubuntu 20.04+ or similar Linux distribution
- Docker and Docker Compose installed
- Root or sudo access
- Public IP address or domain name

## Quick Deployment Steps

### 1. Prepare the Server

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose -y

# Add your user to docker group (optional, for non-root usage)
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Clone and Deploy

```bash
# Clone the repository
git clone <your-repo-url>
cd MCPServer

# Build and start the server
docker-compose up -d

# Verify it's running
docker-compose ps
curl http://localhost:3000/health
```

### 3. Configure Firewall

```bash
# Allow port 3000
sudo ufw allow 3000/tcp
sudo ufw enable
sudo ufw status
```

### 4. Test the Server

```bash
# Run the test script
./test-mcp-connection.sh
```

## Production Considerations

### Using a Reverse Proxy (Nginx)

For production, it's recommended to use Nginx as a reverse proxy:

```bash
# Install Nginx
sudo apt install nginx -y

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/mcp-server
```

Add the following configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/mcp-server /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal is configured automatically
sudo certbot renew --dry-run
```

### Monitoring and Logs

```bash
# View logs
docker-compose logs -f

# Check container status
docker-compose ps

# Restart if needed
docker-compose restart

# View resource usage
docker stats rickmorty-mcp-server
```

### Auto-restart on Server Reboot

The `docker-compose.yml` already includes `restart: unless-stopped`, so the container will automatically restart if the server reboots.

To ensure Docker starts on boot:

```bash
sudo systemctl enable docker
```

### Backup and Updates

```bash
# Backup configuration
cp docker-compose.yml docker-compose.yml.backup

# Update to new version
git pull
docker-compose down
docker-compose build
docker-compose up -d

# View logs to verify
docker-compose logs -f
```

## Claude API Configuration

After deploying, configure Claude API to use your MCP server.

### For HTTP (Development)

```json
{
  "mcpServers": {
    "rickmorty": {
      "url": "http://your-server-ip:3000/sse",
      "transport": "sse"
    }
  }
}
```

### For HTTPS (Production with Nginx + SSL)

```json
{
  "mcpServers": {
    "rickmorty": {
      "url": "https://your-domain.com/sse",
      "transport": "sse"
    }
  }
}
```

## Troubleshooting

### Server Not Responding

```bash
# Check if container is running
docker-compose ps

# View logs
docker-compose logs -f

# Restart container
docker-compose restart
```

### Port Already in Use

```bash
# Find what's using port 3000
sudo lsof -i :3000

# Kill the process or change PORT in docker-compose.yml
```

### Connection Timeout

```bash
# Check firewall
sudo ufw status

# Check if server is listening
sudo netstat -tlnp | grep 3000
```

### Out of Memory

```bash
# Check memory usage
free -h
docker stats

# Add memory limit to docker-compose.yml:
services:
  rickmorty-mcp:
    mem_limit: 512m
```

## Security Best Practices

1. **Firewall**: Only allow necessary ports
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow ssh
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 3000/tcp  # Only if not using reverse proxy
   ```

2. **Authentication**: Add authentication in Nginx if needed
   ```nginx
   location / {
       auth_basic "Restricted Access";
       auth_basic_user_file /etc/nginx/.htpasswd;
       # ... rest of proxy config
   }
   ```

3. **Rate Limiting**: Add rate limiting in Nginx
   ```nginx
   limit_req_zone $binary_remote_addr zone=mcp_limit:10m rate=10r/s;

   server {
       location / {
           limit_req zone=mcp_limit burst=20 nodelay;
           # ... rest of config
       }
   }
   ```

4. **Regular Updates**
   ```bash
   # Update system packages weekly
   sudo apt update && sudo apt upgrade -y

   # Update Docker images
   docker-compose pull
   docker-compose up -d
   ```

## Performance Tuning

### Increase Connection Limits

Edit `docker-compose.yml`:

```yaml
services:
  rickmorty-mcp:
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
```

### Enable Compression in Nginx

```nginx
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript;
```

## Monitoring

### Basic Health Monitoring Script

Create `/opt/monitor-mcp.sh`:

```bash
#!/bin/bash

HEALTH_URL="http://localhost:3000/health"
SLACK_WEBHOOK="your-slack-webhook-url"  # Optional

if ! curl -sf $HEALTH_URL > /dev/null; then
    echo "MCP Server is down! Restarting..."
    cd /path/to/MCPServer
    docker-compose restart

    # Optional: Send Slack notification
    curl -X POST $SLACK_WEBHOOK \
        -H 'Content-Type: application/json' \
        -d '{"text":"MCP Server was down and has been restarted"}'
fi
```

Add to crontab:

```bash
crontab -e
# Add this line to check every 5 minutes
*/5 * * * * /opt/monitor-mcp.sh
```

## Scaling

For high load scenarios:

1. **Multiple Instances**: Use a load balancer (HAProxy, Nginx) with multiple MCP server instances
2. **Caching**: Implement Redis caching for frequent API calls
3. **CDN**: Use a CDN for static responses if applicable

## Support

For issues:
- Check logs: `docker-compose logs -f`
- Review this guide
- Check main README.md
- Open an issue on GitHub
