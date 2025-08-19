# Whoami Deployment Example

This example demonstrates how to deploy a simple `whoami` service to a Traefik reverse proxy using the ephemeral Tailscale deployment pattern.

## What is Whoami?

The `whoami` service is a simple HTTP server that displays information about the HTTP request it receives. It's perfect for testing Traefik configurations and demonstrating the deployment pattern.

## Prerequisites

1. **Tailscale Network**: You must have a Tailscale network with at least one server running Traefik
2. **Traefik Server**: A server running Traefik v2+ with Docker support
3. **GitHub Repository**: This example assumes you're deploying from a GitHub repository
4. **Domain**: A domain name with DNS configured to point to your Traefik server

## Required Secrets

Configure these secrets in your GitHub repository:

| Secret | Description |
|--------|-------------|
| `TS_OAUTH_CLIENT_ID` | Tailscale OAuth client ID |
| `TS_OAUTH_SECRET` | Tailscale OAuth secret |
| `SSH_KEY` | SSH private key for server access |

## Configuration

### 1. Update Environment Variables

Edit the `.github/workflows/deploy.yml` file and update these values:

```yaml
env:
  TAILSCALE_HOST: "your-traefik-host"  # Your Tailscale hostname
  TAILSCALE_IP: "100.64.0.0"           # Your Tailscale IP
  TARGET_USER: "your-username"          # Your server username
  APP_NAME: "whoami"
  DEPLOY_PATH: "/opt/apps/whoami"       # Path on target server
```

### 2. Update Domain Configuration

In `docker-compose.yml`, update the hostname:

```yaml
- "traefik.http.routers.whoami.rule=Host(`whoami.yourdomain.com`)"
```

### 3. Update Health Check URL

In the workflow, update the health check URL:

```yaml
if curl -f -s https://whoami.yourdomain.com > /dev/null; then
```

## Deployment Process

1. **Validation**: The workflow first validates your YAML and Docker Compose configuration
2. **Tailscale Setup**: Creates an ephemeral Tailscale node with CI tags
3. **SSH Setup**: Configures SSH authentication using your private key
4. **Backup**: Creates a backup of the existing deployment (if any)
5. **Deployment**: Copies the configuration and starts the containers
6. **Health Check**: Verifies the application is responding
7. **Cleanup**: Removes sensitive files from the runner

## Security Features

- **Ephemeral Authentication**: Each deployment creates a new Tailscale node
- **Zero Trust Network**: Uses Tailscale's secure networking
- **No Persistent Credentials**: SSH keys are only available during deployment
- **Automatic Cleanup**: Sensitive files are removed after deployment
- **Health Verification**: Ensures the deployment was successful

## Monitoring and Debugging

### Check Deployment Status

```bash
# On your Traefik server
cd /opt/apps/whoami
docker compose ps
docker compose logs -f
```

### Access the Application

Once deployed, your whoami service will be available at:
```
https://whoami.yourdomain.com
```

### Check Traefik Dashboard

Access your Traefik dashboard to see the service configuration and status.

## Troubleshooting

### Common Issues

1. **Tailscale Connectivity**: Ensure your server is accessible via Tailscale
2. **SSH Authentication**: Verify your SSH key has access to the target server
3. **Docker Permissions**: Ensure the target user can run Docker commands
4. **Network Configuration**: Verify the `web` network exists and is accessible

### Debug Commands

```bash
# Test Tailscale connectivity
tailscale ping your-traefik-host

# Check SSH connection
ssh -i ~/.ssh/id_ed25519 your-username@your-traefik-host

# Verify Docker network
docker network ls | grep web
```

## Customization

### Adding More Services

You can extend this pattern to deploy multiple services by:

1. Adding more services to the `docker-compose.yml`
2. Updating the health check to verify all services
3. Adjusting resource limits and configurations

### Environment-Specific Configurations

Create different workflow files for different environments:

- `.github/workflows/deploy-staging.yml`
- `.github/workflows/deploy-production.yml`

### Advanced Traefik Configuration

Add more Traefik labels for:

- Rate limiting
- Authentication
- Load balancing
- Monitoring and metrics

## Next Steps

1. **Customize the Configuration**: Update the domain and server details
2. **Test the Deployment**: Push to your main branch to trigger deployment
3. **Monitor the Service**: Check logs and Traefik dashboard
4. **Scale Up**: Deploy additional services using the same pattern

## Support

For issues or questions:

1. Check the GitHub Actions logs for detailed error messages
2. Verify your Tailscale and SSH configuration
3. Ensure all required secrets are properly configured
4. Check the Traefik server logs for configuration issues
