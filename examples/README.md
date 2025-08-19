# 📚 EGAD Deployment Examples

This directory contains complete, working examples of the **EGAD** (Ephemeral GitHub Action Deployer) deployment pattern for different types of applications.

## 🎯 Available Examples

### 1. **Whoami Service** - `whoami-deployment/`
A simple HTTP service that displays request information. Perfect for testing and learning the pattern.

**Features:**
- Basic Traefik configuration
- SSL certificate management
- Security headers
- Health checks
- Complete GitHub Actions workflow

**Use Case:** Learning the pattern, testing Traefik configurations, simple web services

**Difficulty:** ⭐ Beginner

---

### 2. **NTFY Integration** - `ntfy-integration/`
Complete NTFY notification setup for EGAD deployments with real-time alerts and monitoring.

**Features:**
- NTFY server configuration
- Notification examples and templates
- GitHub Actions integration
- Priority and tag management
- Security considerations

**Use Case:** Adding real-time notifications to deployments, monitoring deployment status

**Difficulty:** ⭐ Beginner

---


**Difficulty:** ⭐⭐⭐ Advanced

## 🚀 How to Use These Examples

### Step 1: Choose Your Example
Select the example that best matches your needs and skill level.

### Step 2: Copy the Configuration
```bash
# Copy the example to your repository
cp -r examples/whoami-deployment/* your-repo/

# Or clone and copy specific examples
git clone https://github.com/yourusername/ephemeral-github-action-deployer.git
cp -r ephemeral-github-action-deployer/examples/whoami-deployment/* your-repo/
```

### Step 3: Customize for Your Environment
1. Update environment variables in the workflow
2. Modify domain names and server details
3. Adjust resource limits and configurations
4. Add your specific requirements

### Step 4: Deploy
1. Push to your main branch
2. Monitor the GitHub Actions workflow
3. Verify the deployment
4. Access your application

## 🔧 Customization Guide

### Basic Customizations

#### Update Environment Variables
```yaml
# In .github/workflows/deploy.yml
env:
  TAILSCALE_HOST: "your-server-hostname"
  TAILSCALE_IP: "100.64.0.0"
  TARGET_USER: "your-username"
  APP_NAME: "your-app-name"
  DEPLOY_PATH: "/opt/apps/your-app"
```

#### Update Domain Configuration
```yaml
# In docker-compose.yml
- "traefik.http.routers.yourapp.rule=Host(`yourapp.yourdomain.com`)"
```

#### Update Health Check URLs
```yaml
# In the workflow health check step
if curl -f -s https://yourapp.yourdomain.com > /dev/null; then
```

### Advanced Customizations

#### Add Multiple Services
```yaml
services:
  app:
    # Your main application
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`app.yourdomain.com`)"
  
  database:
    # Database service
    labels:
      - "traefik.enable=false"  # Internal only
  
  cache:
    # Cache service
    labels:
      - "traefik.enable=false"  # Internal only
```

#### Add Environment-Specific Configurations
```yaml
# Create multiple workflow files
.github/workflows/deploy-staging.yml
.github/workflows/deploy-production.yml

# Use different configurations for each environment
env:
  ENVIRONMENT: staging
  DOMAIN: staging.yourdomain.com
  RESOURCE_LIMITS: "cpus: '0.5', memory: 512M"
```

#### Add Monitoring and Logging
```yaml
services:
  app:
    labels:
      # Prometheus metrics
      - "traefik.http.services.app.loadbalancer.server.port=8080"
      - "traefik.http.routers.app.middlewares=app-metrics"
      - "traefik.http.middlewares.app-metrics.prometheus=true"
    
    # Health checks
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## 📋 Example Checklist

Before deploying any example, ensure you have:

- [ ] **Tailscale Network**: Active Tailscale account and network
- [ ] **Server Access**: SSH access to your target server
- [ ] **Docker**: Docker and Docker Compose installed
- [ ] **Traefik**: Traefik running and configured
- [ ] **Domain**: DNS configured for your services
- [ ] **GitHub Secrets**: All required secrets configured
- [ ] **Network**: `web` network exists in Docker

## 🔍 Troubleshooting Examples

### Common Issues

1. **Tailscale Connectivity**
   - Verify ACLs allow CI nodes
   - Check network connectivity
   - Ensure proper tagging

2. **SSH Authentication**
   - Verify SSH key permissions
   - Check server SSH configuration
   - Test connection manually

3. **Docker Issues**
   - Verify Docker permissions
   - Check network configuration
   - Review container logs

4. **Traefik Configuration**
   - Check label syntax
   - Verify network connectivity
   - Review Traefik logs

### Debug Commands

```bash
# Test Tailscale connectivity
tailscale ping your-server

# Test SSH connection
ssh -i ~/.ssh/key your-user@your-server

# Check Docker status
docker ps
docker network ls

# Check Traefik configuration
docker exec traefik traefik version
docker logs traefik
```

## 📚 Learning Path

### Beginner Level
1. Start with the **whoami-deployment** example
2. Understand the basic workflow
3. Customize for your environment
4. Deploy and test

### Intermediate Level
1. Modify the whoami example
2. Add multiple services
3. Implement health checks
4. Add monitoring

### Advanced Level
1. Create custom examples
2. Implement complex architectures
3. Add security features
4. Optimize performance

## 🤝 Contributing Examples

We welcome contributions of new examples! To contribute:

1. **Fork the repository**
2. **Create a new example directory**
3. **Include complete documentation**
4. **Test thoroughly**
5. **Submit a pull request**

### Example Requirements

Each example should include:

- `README.md` with comprehensive documentation
- `docker-compose.yml` with Traefik labels
- `.github/workflows/deploy.yml` workflow
- Configuration examples
- Troubleshooting guide
- Security considerations

## 📞 Support

- **Documentation**: Visit the [main README](../README.md)
- **Examples**: Check the specific example directories
- **Issues**: Open an issue in the repository
- **Community**: Join Tailscale and Traefik communities

---

**Ready to deploy with EGAD? Choose an example and get started! 🚀**
