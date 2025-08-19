# 🚀 EGAD Complete Deployment Guide

This guide walks you through setting up the **EGAD** (Ephemeral GitHub Action Deployer) pattern from scratch.

## 📋 Prerequisites Checklist

Before you begin, ensure you have:

- [ ] A Tailscale account and network
- [ ] A server running Traefik v2+ with Docker
- [ ] A GitHub repository for your deployment configurations
- [ ] A domain name with DNS access
- [ ] Basic familiarity with Docker, SSH, and GitHub Actions

## 🔧 Step 1: Tailscale Setup

### 1.1 Create Tailscale OAuth App

1. Go to [Tailscale Admin Console](https://login.tailscale.com/admin/oauth)
2. Click "New OAuth App"
3. Configure the app:
   - **Name**: `GitHub Actions Deployer`
   - **Description**: `Ephemeral nodes for secure deployments`
   - **Redirect URLs**: `https://github.com/yourusername/yourrepo`
4. Copy the **Client ID** and **Client Secret**

### 1.2 Configure Tailscale ACLs

Add this to your `tailscale.acl` file:

```json
{
  "tagOwners": {
    "tag:ci": ["your-email@domain.com"],
    "tag:deployment": ["your-email@domain.com"]
  },
  "groups": {
    "group:deployers": ["your-email@domain.com"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["tag:ci", "tag:deployment"],
      "dst": ["your-server:22", "your-server:80", "your-server:443"]
    }
  ]
}
```

## 🐳 Step 2: Traefik Server Setup

### 2.1 Install Docker and Docker Compose

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login again for group changes to take effect
```

### 2.2 Create Traefik Configuration

Create `/opt/traefik/docker-compose.yml`:

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v3.3.6
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - web
    ports:
      - 80:80
      - 443:443
    environment:
      CF_DNS_API_TOKEN: ${CF_DNS_API_TOKEN}
    env_file: .env
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/traefik.yml:ro
      - ./acme.json:/acme.json
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.entrypoints=https"
      - "traefik.http.routers.traefik.rule=Host(`traefik.yourdomain.com`)"
      - "traefik.http.routers.traefik.tls=true"
      - "traefik.http.routers.traefik.tls.certresolver=cloudflare"
      - "traefik.http.routers.traefik.service=api@internal"

networks:
  web:
    external: false
```

### 2.3 Create Traefik Configuration File

Create `/opt/traefik/traefik.yml`:

```yaml
api:
  dashboard: true
  debug: false

entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https
  https:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: web

certificatesResolvers:
  cloudflare:
    acme:
      email: your-email@domain.com
      storage: acme.json
      dnsChallenge:
        provider: cloudflare
        disablePropagationCheck: true
        delayBeforeCheck: 30s
```

### 2.4 Create Environment File

Create `/opt/traefik/.env`:

```bash
CF_DNS_API_TOKEN=your_cloudflare_api_token
```

### 2.5 Create ACME Storage File

```bash
cd /opt/traefik
touch acme.json
chmod 600 acme.json
```

### 2.6 Start Traefik

```bash
cd /opt/traefik
docker-compose up -d
```

## 🔑 Step 3: SSH Key Setup

### 3.1 Generate SSH Key Pair

```bash
# Generate a new SSH key pair
ssh-keygen -t ed25519 -C "github-actions-deployer" -f ~/.ssh/github_actions

# Copy the public key to your server
ssh-copy-id -i ~/.ssh/github_actions.pub your-username@your-server
```

### 3.2 Test SSH Connection

```bash
ssh -i ~/.ssh/github_actions your-username@your-server
```

## 🌐 Step 4: Domain and DNS Setup

### 4.1 Configure DNS Records

In your DNS provider (e.g., Cloudflare):

```
Type    Name                    Value
A       traefik                 YOUR_SERVER_IP
A       whoami                  YOUR_SERVER_IP
CNAME   *.yourdomain.com        yourdomain.com
```

### 4.2 Cloudflare API Token (if using Cloudflare)

1. Go to Cloudflare Dashboard → Profile → API Tokens
2. Create Custom Token with these permissions:
   - Zone:Zone:Read
   - Zone:DNS:Edit
   - Zone:Zone Settings:Read

## 📁 Step 5: GitHub Repository Setup

### 5.1 Create Repository Structure

```bash
mkdir my-deployment-repo
cd my-deployment-repo

# Copy the example files
cp -r examples/whoami-deployment/* .
```

### 5.2 Configure GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions:

- `TS_OAUTH_CLIENT_ID`: Your Tailscale OAuth client ID
- `TS_OAUTH_SECRET`: Your Tailscale OAuth client secret
- `SSH_KEY`: Your private SSH key content

### 5.3 Update Configuration Files

1. **Update `.github/workflows/deploy.yml`**:
   ```yaml
   env:
     TAILSCALE_HOST: "your-traefik-host"
     TAILSCALE_IP: "100.64.0.0"
     TARGET_USER: "your-username"
     APP_NAME: "whoami"
     DEPLOY_PATH: "/opt/apps/whoami"
   ```

2. **Update `docker-compose.yml`**:
   ```yaml
   - "traefik.http.routers.whoami.rule=Host(`whoami.yourdomain.com`)"
   ```

3. **Update health check URL** in the workflow

## 🚀 Step 6: First Deployment

### 6.1 Push to Main Branch

```bash
git add .
git commit -m "Initial deployment configuration"
git push origin main
```

### 6.2 Monitor Deployment

1. Go to GitHub → Actions tab
2. Watch the deployment workflow
3. Check for any errors

### 6.3 Verify Deployment

```bash
# Check if containers are running
ssh your-username@your-server "cd /opt/apps/whoami && docker compose ps"

# Check Traefik logs
ssh your-username@your-server "docker logs traefik"

# Test the endpoint
curl -k https://whoami.yourdomain.com
```

## 🔍 Step 7: Troubleshooting

### Common Issues and Solutions

#### 1. Tailscale Connectivity Issues

```bash
# Check Tailscale status
tailscale status

# Test connectivity
tailscale ping your-server

# Check ACLs
tailscale netcheck
```

#### 2. SSH Authentication Issues

```bash
# Test SSH with verbose output
ssh -vvv -i ~/.ssh/github_actions your-username@your-server

# Check SSH server logs
sudo journalctl -u ssh -f
```

#### 3. Docker Permission Issues

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Check docker group membership
groups $USER
```

#### 4. Traefik Configuration Issues

```bash
# Check Traefik configuration
docker exec traefik traefik version

# View Traefik logs
docker logs traefik

# Check Traefik dashboard
curl http://localhost:8080/api/http/routers
```

## 📊 Step 8: Monitoring and Maintenance

### 8.1 Health Checks

Add monitoring to your deployment workflow:

```yaml
- name: Health Check
  run: |
    # Wait for application to be ready
    sleep 30
    
    # Test multiple endpoints
    for endpoint in "https://whoami.yourdomain.com" "https://traefik.yourdomain.com"; do
      if ! curl -f -s "$endpoint" > /dev/null; then
        echo "❌ Health check failed for $endpoint"
        exit 1
      fi
      echo "✅ $endpoint is healthy"
    done
```

### 8.2 Logging and Notifications

Configure notifications for deployment status:

```yaml
- name: Notify on Success
  if: success()
  run: |
    curl -H "Content-Type: application/json" \
         -d '{"text":"✅ Deployment successful!"}' \
         ${{ secrets.SLACK_WEBHOOK_URL }}
```

### 8.3 Backup Strategy

Implement automated backups:

```bash
#!/bin/bash
# backup.sh
BACKUP_DIR="/home/$USER/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup Docker volumes
docker run --rm -v /opt/apps:/data -v "$BACKUP_DIR":/backup \
  alpine tar -czf "/backup/apps_backup_$DATE.tar.gz" -C /data .

# Cleanup old backups (keep last 7 days)
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete
```

## 🔒 Step 9: Security Hardening

### 9.1 Firewall Configuration

```bash
# Configure UFW firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 9.2 SSH Hardening

Edit `/etc/ssh/sshd_config`:

```bash
# Disable password authentication
PasswordAuthentication no

# Disable root login
PermitRootLogin no

# Use key-based authentication only
PubkeyAuthentication yes

# Restrict users
AllowUsers your-username

# Restart SSH service
sudo systemctl restart ssh
```

### 9.3 Docker Security

```bash
# Create non-root user for Docker
sudo useradd -r -s /bin/false docker-user

# Update docker-compose.yml to use non-root user
services:
  whoami:
    user: "1000:1000"  # Use UID:GID
```

## 📈 Step 10: Scaling and Advanced Features

### 10.1 Multiple Environments

Create environment-specific workflows:

```yaml
# .github/workflows/deploy-staging.yml
env:
  ENVIRONMENT: staging
  DOMAIN: staging.yourdomain.com

# .github/workflows/deploy-production.yml
env:
  ENVIRONMENT: production
  DOMAIN: yourdomain.com
```

### 10.2 Load Balancing

Add multiple instances:

```yaml
services:
  whoami:
    deploy:
      replicas: 3
    labels:
      - "traefik.http.services.whoami.loadbalancer.sticky.cookie=true"
```

### 10.3 Monitoring and Metrics

Enable Prometheus metrics:

```yaml
# In traefik.yml
metrics:
  prometheus:
    buckets:
      - 0.1
      - 0.3
      - 1.2
      - 5.0
```

## 🎯 Next Steps

1. **Customize the Configuration**: Adapt for your specific needs
2. **Add More Services**: Deploy additional applications
3. **Implement CI/CD**: Add testing and validation steps
4. **Monitor Performance**: Set up logging and alerting
5. **Document Your Setup**: Create runbooks for your team

## 🆘 Getting Help

- **GitHub Issues**: Open an issue in this repository
- **Tailscale Support**: [Tailscale Help Center](https://tailscale.com/help/)
- **Traefik Documentation**: [Traefik Docs](https://doc.traefik.io/traefik/)
- **Community**: Join Tailscale and Traefik communities

---

**Happy Deploying with EGAD! 🚀**
