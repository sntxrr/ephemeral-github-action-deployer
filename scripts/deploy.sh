#!/bin/bash

# Exit on error
set -e

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local timestamp
    timestamp=$(TZ='America/Los_Angeles' date '+%Y-%m-%d %I:%M:%S %p %Z')
    
    curl -H "Title: $title" \
         -H "Authorization: Bearer $NTFY_API_KEY" \
         -d "$message at $timestamp" \
         https://ntfy.sh/traefik-deploy
}

# Function to execute remote commands
execute_remote() {
    local command="$1"
    local error_message="$2"
    
    if ! timeout 10m ssh -o StrictHostKeyChecking=accept-new -o HostKeyAlias=traefik "$TARGET_USER@traefik" "$command"; then
        send_notification "Traefik Deployment Failed" "$error_message"
        exit 1
    fi
}

# Main deployment script
execute_remote "
    # Change to project directory
    cd /home/$TARGET_USER/git/traefik.your-domain.tld

    # Determine which docker compose command to use
    if command -v docker-compose >/dev/null 2>&1; then
        DOCKER_COMPOSE=\"docker-compose\"
    elif docker compose version >/dev/null 2>&1; then
        DOCKER_COMPOSE=\"docker compose\"
    else
        send_notification \"Traefik Deployment Failed\" \"Neither docker-compose nor docker compose is available for commit \$GITHUB_SHA\"
        exit 1
    fi

    # Create backup
    BACKUP_DIR=\"/home/$TARGET_USER/backups/traefik\"
    mkdir -p \$BACKUP_DIR
    BACKUP_FILE=\"\$BACKUP_DIR/traefik_backup_\$(date +%Y%m%d_%H%M%S).tar.gz\"
    
    # Stop containers before backup
    eval \"\$DOCKER_COMPOSE down\" || true
    
    # Create backup with error handling
    if ! tar -czf \$BACKUP_FILE .; then
        send_notification \"Traefik Backup Failed\" \"Failed to create backup for commit \$GITHUB_SHA\"
        exit 1
    fi
    
    # Verify backup was created and has content
    if [ ! -s \$BACKUP_FILE ]; then
        send_notification \"Traefik Backup Failed\" \"Backup file is empty or was not created for commit \$GITHUB_SHA\"
        exit 1
    fi

    # Pull latest changes
    if ! git fetch origin main && git reset --hard origin/main; then
        send_notification \"Traefik Deployment Failed\" \"Failed to pull latest changes for commit \$GITHUB_SHA\"
        exit 1
    fi

    # Start containers and check health
    if ! eval \"\$DOCKER_COMPOSE up -d\"; then
        send_notification \"Traefik Deployment Failed\" \"Failed to start containers for commit \$GITHUB_SHA\"
        exit 1
    fi

    # Wait and verify containers are running
    sleep 10
    if ! eval \"\$DOCKER_COMPOSE ps\" | grep -q \"Up\"; then
        send_notification \"Traefik Deployment Failed\" \"Containers failed to start properly for commit \$GITHUB_SHA\"
        exit 1
    fi
" "Deployment failed for commit $GITHUB_SHA. Check GitHub Actions for details." 