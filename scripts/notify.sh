#!/bin/bash

# Exit on error
set -e

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local priority="${3:-default}"
    local tags="${4:-rocket,deployment}"
    local timestamp
    timestamp=$(TZ='America/Los_Angeles' date '+%Y-%m-%d %I:%M:%S %p %Z')
    
    # Add PR information if available
    if [ -n "$GITHUB_PR_NUMBER" ] && [ -n "$GITHUB_PR_TITLE" ]; then
        message="$message (PR #$GITHUB_PR_NUMBER: $GITHUB_PR_TITLE)"
    fi
    
    # Use NTFY_SERVER and NTFY_TOPIC if available, fallback to defaults
    local ntfy_server="${NTFY_SERVER:-https://ntfy.sh}"
    local ntfy_topic="${NTFY_TOPIC:-traefik-deploy}"
    
    curl -H "Title: $title" \
         -H "Priority: $priority" \
         -H "Tags: $tags" \
         -H "Authorization: Bearer $NTFY_API_KEY" \
         -d "$message at $timestamp" \
         "$ntfy_server/$ntfy_topic"
}

# Check if required environment variables are set
if [ -z "$NTFY_API_KEY" ]; then
    echo "Error: NTFY_API_KEY environment variable is not set"
    exit 1
fi

if [ -z "$GITHUB_SHA" ]; then
    echo "Error: GITHUB_SHA environment variable is not set"
    exit 1
fi

# Get notification context (deploy or validate)
context=${2:-"deploy"}

# Send notification based on status and context
if [ "$1" = "start" ]; then
    if [ "$context" = "deploy" ]; then
        send_notification "🚀 EGAD Deployment Started" "Starting deployment process for commit $GITHUB_SHA" "default" "rocket,deployment"
    elif [ "$context" = "validate" ]; then
        send_notification "🔍 EGAD Validation Started" "Starting validation checks for commit $GITHUB_SHA" "default" "magnifying_glass,validation"
    else
        echo "Error: Invalid context. Use 'deploy' or 'validate'"
        exit 1
    fi
elif [ "$1" = "success" ]; then
    if [ "$context" = "deploy" ]; then
        send_notification "✅ EGAD Deployment Success" "Deployment completed successfully for commit $GITHUB_SHA" "low" "white_check_mark,success"
    elif [ "$context" = "validate" ]; then
        send_notification "✅ EGAD Validation Success" "All validation checks passed for commit $GITHUB_SHA" "low" "white_check_mark,success"
    else
        echo "Error: Invalid context. Use 'deploy' or 'validate'"
        exit 1
    fi
elif [ "$1" = "timeout" ]; then
    if [ "$context" = "deploy" ]; then
        send_notification "❌ EGAD Deployment Failed" "Deployment timed out after 10 minutes for commit $GITHUB_SHA" "high" "x,failure,deployment"
    elif [ "$context" = "validate" ]; then
        send_notification "❌ EGAD Validation Failed" "Validation timed out for commit $GITHUB_SHA" "high" "x,failure,validation"
    else
        echo "Error: Invalid context. Use 'deploy' or 'validate'"
        exit 1
    fi
else
    echo "Error: Invalid notification type. Use 'start', 'success', or 'timeout'"
    exit 1
fi 