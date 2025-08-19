# 🔔 NTFY Integration with EGAD

This example demonstrates how to integrate NTFY notifications with your EGAD deployments for real-time updates and alerts.

## 🎯 What is NTFY?

NTFY (pronounced "notify") is a simple HTTP-based pub-sub notification service. It allows you to send notifications to your phone or desktop via scripts from any computer, entirely without signup, cost or setup.

## 🚀 Why Use NTFY with EGAD?

- **Real-time Updates**: Get instant notifications about deployment status
- **No Account Required**: Simple HTTP-based notifications
- **Cross-platform**: Works on any device with a web browser
- **Customizable**: Set priorities, tags, and custom messages
- **Free**: No cost for basic usage

## 📋 Prerequisites

1. **NTFY Server**: Use the public server or host your own
2. **GitHub Secrets**: Configure NTFY credentials
3. **Web Browser**: To receive notifications

## 🔧 Setup

### 1. Choose Your NTFY Server

**Option A: Public Server (Recommended for testing)**
```
https://ntfy.sh
```

**Option B: Self-hosted Server**
```
https://ntfy.yourdomain.com
```

### 2. Create a Topic

Topics are like channels for notifications. Create a unique topic for your deployments:

```
egad-deployments
egad-prod
egad-staging
```

### 3. Configure GitHub Secrets

Add these secrets to your repository:

| Secret | Description | Example |
|--------|-------------|---------|
| `NTFY_SERVER` | Your NTFY server URL | `https://ntfy.sh` |
| `NTFY_TOPIC` | Your notification topic | `egad-deployments` |
| `NTFY_API_KEY` | Optional: API key for authentication | `tk_1234567890` |

## 📱 Receiving Notifications

### Desktop Notifications

1. Visit your NTFY topic URL: `https://ntfy.sh/egad-deployments`
2. Click "Subscribe to notifications"
3. Allow browser notifications
4. You'll now receive desktop notifications!

### Mobile Notifications

1. Install the NTFY app from your app store
2. Add your topic: `egad-deployments`
3. Configure notification settings
4. Receive push notifications on your phone!

## 🎨 Notification Examples

### Basic Deployment Notification

```bash
curl -H "Title: 🚀 EGAD Deployment Started" \
     -H "Priority: default" \
     -H "Tags: rocket,deployment" \
     -d "Deploying myapp to production" \
     https://ntfy.sh/egad-deployments
```

### Success Notification

```bash
curl -H "Title: ✅ EGAD Deployment Success" \
     -H "Priority: low" \
     -H "Tags: white_check_mark,success" \
     -d "Deployment completed successfully" \
     https://ntfy.sh/egad-deployments
```

### Failure Alert

```bash
curl -H "Title: ❌ EGAD Deployment Failed" \
     -H "Priority: high" \
     -H "Tags: x,failure,deployment" \
     -d "Deployment failed - check logs" \
     https://ntfy.sh/egad-deployments
```

## 🔄 Integration with GitHub Actions

### Enhanced Workflow with NTFY

```yaml
name: EGAD Deployment with NTFY

on:
  push:
    branches: [main]

env:
  NTFY_SERVER: ${{ secrets.NTFY_SERVER }}
  NTFY_TOPIC: ${{ secrets.NTFY_TOPIC }}
  NTFY_API_KEY: ${{ secrets.NTFY_API_KEY }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Notify deployment start
        run: |
          curl -H "Title: 🚀 EGAD Deployment Started" \
               -H "Priority: default" \
               -H "Tags: rocket,deployment" \
               -d "Starting deployment of ${{ github.repository }}" \
               ${{ secrets.NTFY_SERVER }}/${{ secrets.NTFY_TOPIC }}
      
      - name: Setup Tailscale
        uses: tailscale/github-action@v2
        with:
          oauth-client-id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
          oauth-secret: ${{ secrets.TS_OAUTH_SECRET }}
      
      - name: Deploy
        run: |
          # Your deployment logic here
          echo "Deploying application..."
      
      - name: Notify success
        if: success()
        run: |
          curl -H "Title: ✅ EGAD Deployment Success" \
               -H "Priority: low" \
               -H "Tags: white_check_mark,success" \
               -d "Deployment completed successfully" \
               ${{ secrets.NTFY_SERVER }}/${{ secrets.NTFY_TOPIC }}
      
      - name: Notify failure
        if: failure()
        run: |
          curl -H "Title: ❌ EGAD Deployment Failed" \
               -H "Priority: high" \
               -H "Tags: x,failure,deployment" \
               -d "Deployment failed - check logs" \
               ${{ secrets.NTFY_SERVER }}/${{ secrets.NTFY_TOPIC }}
```

### Using the Enhanced Notify Script

```yaml
      - name: Notify deployment start
        run: ./scripts/notify.sh "start" "deploy" "default" "rocket,deployment"
      
      - name: Notify success
        if: success()
        run: ./scripts/notify.sh "success" "deploy" "low" "white_check_mark,success"
      
      - name: Notify failure
        if: failure()
        run: ./scripts/notify.sh "timeout" "deploy" "high" "x,failure,deployment"
```

## 🎛️ Advanced Features

### Priority Levels

- **min**: Lowest priority (gray)
- **low**: Low priority (blue)
- **default**: Normal priority (green)
- **high**: High priority (yellow)
- **urgent**: Urgent priority (red)

### Tags

Tags help categorize and visually identify notifications:

- `rocket` - Deployment events
- `white_check_mark` - Success events
- `x` - Failure events
- `magnifying_glass` - Validation events
- `warning` - Warning events
- `rotating_light` - Critical events

### Custom Headers

```bash
curl -H "Title: Custom Title" \
     -H "Priority: high" \
     -H "Tags: custom,tag" \
     -H "Click: https://github.com/your-repo" \
     -H "Icon: https://your-icon.png" \
     -d "Custom message" \
     https://ntfy.sh/egad-deployments
```

## 🔒 Security Considerations

### Authentication

For sensitive deployments, use NTFY authentication:

```bash
# With API key
curl -H "Authorization: Bearer tk_1234567890" \
     -d "Secure notification" \
     https://ntfy.sh/egad-deployments

# With username/password
curl -u username:password \
     -d "Secure notification" \
     https://ntfy.sh/egad-deployments
```

### Self-hosting

For enterprise use, consider self-hosting NTFY:

```yaml
# docker-compose.yml
version: '3.8'
services:
  ntfy:
    image: binwiederhier/ntfy:latest
    ports:
      - "80:80"
    environment:
      - NTFY_BASE_URL=http://ntfy.yourdomain.com
    volumes:
      - ./ntfy:/var/lib/ntfy
```

## 📊 Monitoring and Analytics

### Notification History

View your notification history at:
```
https://ntfy.sh/egad-deployments/json
```

### Webhook Integration

NTFY can forward notifications to other services:

```bash
curl -H "X-Forward-To: https://webhook.site/your-webhook" \
     -d "This will be forwarded" \
     https://ntfy.sh/egad-deployments
```

## 🚀 Best Practices

1. **Use Descriptive Titles**: Make notifications easy to understand
2. **Set Appropriate Priorities**: Don't overuse high priority
3. **Include Relevant Tags**: Help categorize notifications
4. **Add Context**: Include commit hashes, environment info
5. **Test Notifications**: Verify your setup works before deployment
6. **Monitor Usage**: Keep track of notification volume

## 🔍 Troubleshooting

### Common Issues

1. **No Notifications Received**
   - Check browser notification permissions
   - Verify NTFY server is accessible
   - Check topic name spelling

2. **Authentication Errors**
   - Verify API key format
   - Check username/password
   - Ensure proper Authorization header

3. **Rate Limiting**
   - Public servers have rate limits
   - Consider self-hosting for high volume
   - Implement notification batching

### Debug Commands

```bash
# Test basic connectivity
curl -v https://ntfy.sh/egad-deployments

# Test with authentication
curl -H "Authorization: Bearer $NTFY_API_KEY" \
     -d "Test message" \
     https://ntfy.sh/egad-deployments

# Check notification history
curl https://ntfy.sh/egad-deployments/json
```

## 📚 Additional Resources

- [NTFY Official Documentation](https://docs.ntfy.sh/)
- [NTFY GitHub Repository](https://github.com/binwiederhier/ntfy)
- [NTFY Mobile Apps](https://docs.ntfy.sh/subscribe/phone/)
- [NTFY Self-hosting Guide](https://docs.ntfy.sh/install/)

---

**Ready to get notified? Set up NTFY with EGAD and never miss a deployment update! 🔔🚀**
