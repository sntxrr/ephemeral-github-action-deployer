#!/bin/bash

# Exit on error
set -e

echo "Debug: Starting SSH setup..."
echo "Debug: Using IP: $TAILSCALE_IP"
echo "Debug: Using hostname: traefik"

# Create .ssh directory in the ephemeral environment
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add the host key to known_hosts using hostname
echo "Debug: Running ssh-keyscan for traefik..."
if ! ssh-keyscan -H traefik >> ~/.ssh/known_hosts; then
    echo "Error: Failed to get SSH host key"
    echo "Debug: Checking if known_hosts was created:"
    ls -l ~/.ssh/known_hosts
    echo "Debug: Contents of known_hosts:"
    cat ~/.ssh/known_hosts
    echo "Debug: Trying with IP as fallback..."
    if ! ssh-keyscan -H "$TAILSCALE_IP" >> ~/.ssh/known_hosts; then
        echo "Error: Failed to get SSH host key from both hostname and IP"
        exit 1
    fi
fi

echo "Debug: Setting known_hosts permissions..."
chmod 644 ~/.ssh/known_hosts

echo "Debug: Creating SSH key..."
# Create and secure the private key
echo "$SSH_KEY" > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519

# Test the key permissions
echo "Debug: SSH directory contents:"
ls -la ~/.ssh/

# Verify the key is readable
if [ ! -r ~/.ssh/id_ed25519 ]; then
    echo "Error: SSH key file is not readable"
    exit 1
fi

# Debug: Show key format and type
echo "Debug: Checking key format:"
head -n 1 ~/.ssh/id_ed25519
echo "Debug: Key type and fingerprint:"
ssh-keygen -l -f ~/.ssh/id_ed25519 || true

# Debug: Show public key
echo "Debug: Public key:"
ssh-keygen -y -f ~/.ssh/id_ed25519 || true

echo "Debug: SSH setup completed successfully" 