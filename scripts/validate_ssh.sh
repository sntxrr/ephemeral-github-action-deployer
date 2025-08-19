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

# Debug information
echo "Debug: Environment variables:"
echo "TAILSCALE_HOST: $TAILSCALE_HOST"
echo "TAILSCALE_IP: $TAILSCALE_IP"
echo "TARGET_USER: $TARGET_USER"
echo "SSH directory contents:"
ls -la ~/.ssh || true

# Test Tailscale connectivity first
echo "Testing Tailscale connectivity to traefik..."
echo "Debug: Running tailscale ping -c 3 traefik..."
if ! tailscale ping -c 3 traefik >/dev/null 2>&1; then
    echo "Debug: First ping attempt failed, trying with IP..."
    if ! tailscale ping -c 3 "$TAILSCALE_IP" >/dev/null 2>&1; then
        echo "Debug: Both hostname and IP ping failed. Checking Tailscale status:"
        tailscale status || true
        echo "Debug: Checking Tailscale version:"
        tailscale version || true
        echo "Debug: Checking Tailscale netcheck:"
        tailscale netcheck || true
        send_notification "Traefik Deployment Failed" "Failed to ping traefik via Tailscale for commit $GITHUB_SHA"
        exit 1
    fi
fi

# Test SSH connection with verbose output
echo "Testing SSH connection to traefik..."
echo "Using command: ssh -vvv -i ~/.ssh/id_ed25519 -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -o HostKeyAlias=traefik -o PreferredAuthentications=publickey $TARGET_USER@traefik \"echo \\\"SSH connection validated\\\"\""
if ! timeout 30s ssh -vvv -i ~/.ssh/id_ed25519 -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -o HostKeyAlias=traefik -o PreferredAuthentications=publickey "$TARGET_USER@traefik" "echo \"SSH connection validated\""; then
    echo "SSH connection failed. Checking SSH configuration:"
    echo "SSH config file contents:"
    cat ~/.ssh/config || true
    echo "Known hosts file contents:"
    cat ~/.ssh/known_hosts || true
    echo "Checking Tailscale status again:"
    tailscale status || true
    echo "Debug: Checking SSH key:"
    ls -l ~/.ssh/id_ed25519 || true
    echo "Debug: Key format:"
    head -n 1 ~/.ssh/id_ed25519 || true
    echo "Debug: Key type and fingerprint:"
    ssh-keygen -l -f ~/.ssh/id_ed25519 || true
    echo "Debug: Public key:"
    ssh-keygen -y -f ~/.ssh/id_ed25519 || true
    send_notification "Traefik Deployment Failed" "Failed to validate SSH connection for commit $GITHUB_SHA"
    exit 1
fi 