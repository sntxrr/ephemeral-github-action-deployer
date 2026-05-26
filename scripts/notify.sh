#!/bin/bash
# Template notification script for EGAD-deployed projects.
#
# Sends deploy notifications via apprise (https://github.com/caronc/apprise-api).
# The default endpoint is the homelab apprise instance reachable only over tailscale;
# override APPRISE_URL / APPRISE_KEY in your project to point at your own setup.

set -e

STATUS="$1"  # start, success, timeout, failure
PHASE="${2:-deploy}"

APPRISE_URL="${APPRISE_URL:-http://docker:3005}"
APPRISE_KEY="${APPRISE_KEY:-deploy-notifications-homelab}"
NOTIFY_TAGS="${NOTIFY_TAGS:-deployment}"

if [ -z "$GITHUB_SHA" ]; then
    echo "Error: GITHUB_SHA environment variable is not set"
    exit 1
fi

TIMESTAMP=$(TZ='America/Los_Angeles' date '+%Y-%m-%d %I:%M:%S %p %Z')
SHORT_SHA="${GITHUB_SHA:0:7}"

PR_SUFFIX=""
if [ -n "$GITHUB_PR_NUMBER" ] && [ -n "$GITHUB_PR_TITLE" ]; then
    PR_SUFFIX=" (PR #$GITHUB_PR_NUMBER: $GITHUB_PR_TITLE)"
fi

case "$STATUS-$PHASE" in
    "start-deploy")
        TITLE="🚀 EGAD Deployment Started"
        MESSAGE="Starting deployment process for commit $SHORT_SHA$PR_SUFFIX at $TIMESTAMP"
        TYPE="info"
        ;;
    "start-validate")
        TITLE="🔍 EGAD Validation Started"
        MESSAGE="Starting validation checks for commit $SHORT_SHA$PR_SUFFIX at $TIMESTAMP"
        TYPE="info"
        ;;
    "success-deploy")
        TITLE="✅ EGAD Deployment Success"
        MESSAGE="Deployment completed successfully for commit $SHORT_SHA$PR_SUFFIX at $TIMESTAMP"
        TYPE="success"
        ;;
    "success-validate")
        TITLE="✅ EGAD Validation Success"
        MESSAGE="All validation checks passed for commit $SHORT_SHA$PR_SUFFIX at $TIMESTAMP"
        TYPE="success"
        ;;
    "timeout-deploy"|"failure-deploy")
        TITLE="❌ EGAD Deployment Failed"
        MESSAGE="Deployment failed for commit $SHORT_SHA$PR_SUFFIX at $TIMESTAMP. Check GitHub Actions for details."
        TYPE="failure"
        ;;
    "timeout-validate"|"failure-validate")
        TITLE="❌ EGAD Validation Failed"
        MESSAGE="Validation failed for commit $SHORT_SHA$PR_SUFFIX at $TIMESTAMP"
        TYPE="failure"
        ;;
    *)
        echo "Error: Invalid notification type. Use start|success|timeout|failure and deploy|validate"
        exit 1
        ;;
esac

curl --max-time 10 -X POST \
     -F "title=$TITLE" \
     -F "body=$MESSAGE" \
     -F "tag=$NOTIFY_TAGS" \
     -F "type=$TYPE" \
     "$APPRISE_URL/notify/$APPRISE_KEY" || echo "apprise notify failed (non-fatal)"
