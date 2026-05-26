# 🔔 Apprise Integration with EGAD

This example demonstrates how to integrate [apprise-api](https://github.com/caronc/apprise-api) notifications with your EGAD deployments for real-time multi-channel alerts.

## 🎯 What is Apprise?

Apprise is a notification fan-out service. You POST one HTTP request to a keyed endpoint and apprise delivers it to every channel you've configured under that key — Matrix, Slack, Discord, Pushover, ntfy, Telegram, email, Gotify, and ~90 others. Adding a new destination later is a config change at the apprise server, not a code change in every project.

## 🚀 Why Use Apprise with EGAD?

- **Multi-channel fan-out**: one POST, many destinations
- **Decouple routing from code**: change where notifications land without touching repos
- **Per-topic keys**: separate "deploy" alerts from "monitoring" alerts at the apprise layer
- **No per-call auth token required**: apprise treats the config key itself as the routing identifier; combine with private networking (tailscale) for the security layer
- **Open source, self-hostable**: runs as a small Docker container

## 📋 Prerequisites

1. **Apprise API server**: A running `caronc/apprise` container (see "Hosting Apprise" below)
2. **A config key**: One or more pre-configured keys (e.g., `deploy-notifications-homelab`) with one or more destination URLs (see [Apprise URL syntax](https://github.com/caronc/apprise/wiki))
3. **Network reachability**: GitHub Actions runners need to be able to reach the apprise endpoint — typically via tailscale, since the runner is ephemeral and the apprise instance is on a private network

## 🔧 Setup

### 1. Stand Up Apprise

Run apprise-api with persistent stateful config storage:

```yaml
services:
  apprise:
    image: caronc/apprise:v1.4.1
    container_name: apprise
    restart: unless-stopped
    ports:
      - "3005:8000"
    environment:
      - APPRISE_STATEFUL_MODE=simple
      - APPRISE_WORKER_COUNT=1
    volumes:
      - ./config:/config
```

`/config/store/<key>/` holds each keyed config. The container is reachable at `http://<host>:3005/`.

### 2. Save a Config Key

Pick a name (e.g., `deploy-notifications-homelab`) and POST a config to `/add/<key>`:

```bash
curl -X POST \
  -F "format=yaml" \
  -F "config=urls:
  - matrixs://bot:PASSWORD@matrix.example.org/!ROOMID:matrix.example.org
  - discord://WEBHOOK_ID/WEBHOOK_TOKEN
  - pover://USER@TOKEN" \
  http://apprise.example/add/deploy-notifications-homelab
```

The same key can carry multiple destination URLs; apprise fans every notify out to all of them. Adding a fourth channel later is just re-posting the same config with one more URL — no repo changes anywhere.

### 3. Configure Workflow Env

In your `.github/workflows/deploy.yml`:

```yaml
env:
  APPRISE_URL: "http://docker:3005"
  APPRISE_KEY: "deploy-notifications-homelab"
  NOTIFY_TAGS: "your-service,deployment"
```

`APPRISE_URL` should be reachable from the runner *after tailscale comes up*. If your apprise is on the tailnet, the runner must bring up tailscale before any notify step runs.

## 📱 Receiving Notifications

Whatever channels you put in the keyed config will receive every notify. Some common destinations:

| Service | Apprise URL pattern |
|---|---|
| Matrix | `matrixs://user:pass@homeserver/!roomid:server` |
| Discord | `discord://webhook_id/webhook_token` |
| Slack | `slack://TokenA/TokenB/TokenC/#Channel` |
| Pushover | `pover://user@token` |
| ntfy.sh | `ntfy://ntfy.sh/topic` |
| Gotify | `gotify://hostname/token` |
| Email | `mailto://user:pass@smtp.example.com` |

See [Apprise URL syntax](https://github.com/caronc/apprise/wiki) for the full list.

## 🎨 Notification Examples

### Basic Deployment Notification

```bash
curl --max-time 10 -X POST \
     -F "title=🚀 Deployment Started" \
     -F "body=Deploying commit $GITHUB_SHA at $(date)" \
     -F "tag=deployment" \
     -F "type=info" \
     "$APPRISE_URL/notify/$APPRISE_KEY"
```

### Success / Failure with Type

Apprise's `type` field (info / success / warning / failure) maps to icons and severity styling in destinations like Discord, Slack, and ntfy:

```bash
# Success
-F "type=success"

# Failure
-F "type=failure"
```

### With Tags

```bash
-F "tag=deployment,production,critical"
```

Some destinations use tags for filtering/routing within their UI.

## 🛠️ Drop-in `notify.sh`

This repository ships `scripts/notify.sh` as a ready-to-use wrapper. Copy it into your project and call it from your workflow:

```yaml
- name: Notify on deploy success
  if: success()
  run: ./scripts/notify.sh "success" "deploy"

- name: Notify on deploy failure
  if: failure()
  run: ./scripts/notify.sh "failure" "deploy"
```

The script reads `APPRISE_URL`, `APPRISE_KEY`, and `NOTIFY_TAGS` from the environment.

## 🔐 Security Considerations

### Apprise's threat model

Apprise-api has no built-in authentication on `/notify/<key>`. Anyone who can reach the endpoint and knows (or guesses) a key can send to it. Pick one of these layers:

1. **Tailscale-only access (recommended for homelab):** bind apprise to an interface only reachable on the tailnet. The key acts as a secondary identifier, but the network controls access.
2. **Basic auth via reverse proxy:** put traefik/nginx in front with HTTP basic auth on `/notify/*`.
3. **Per-key bearer token:** custom middleware that checks an `Authorization` header before passing through.

For ephemeral GitHub Actions runners, option 1 is simplest: have the runner `tailscale up` before notifying, and `tailscale logout` in cleanup.

### Don't echo the URL in logs

Avoid `set -x` in scripts that build the apprise URL, and don't `echo` the full URL — the key is the only routing identifier and logs are often shared.

## 🐛 Troubleshooting

### Notification didn't arrive

```bash
# Confirm apprise is reachable
curl -m 3 "$APPRISE_URL/status"   # expect: OK

# Confirm the key exists
curl "$APPRISE_URL/get/$APPRISE_KEY"   # expect: YAML config

# Send a test directly
curl -X POST \
  -F "title=test" -F "body=hello" \
  "$APPRISE_URL/notify/$APPRISE_KEY"
```

Apprise's own logs (`docker logs apprise`) will show each notify and any per-destination errors.

### "curl: (6) Could not resolve host"

The runner couldn't resolve `$APPRISE_URL`. If you're using a tailscale magic-DNS name like `docker`, make sure `tailscale up` ran successfully before this step.

### Matrix room: bot isn't in the room

Apprise's Matrix plugin can sometimes auto-accept the room invite on first send, but the most reliable pattern is to invite the bot manually and have it accept once before relying on it. End-to-end encrypted rooms require apprise's olm support — easiest is a non-encrypted room for notifications.

## 🔄 Migrating from ntfy

If you previously hit ntfy with the `Title:` / `Priority:` / `Tags:` header pattern:

| ntfy | apprise |
|---|---|
| `POST /<topic>` | `POST /notify/<key>` |
| `Title: ...` header | `-F "title=..."` form field |
| `Tags: ...` header | `-F "tag=..."` form field |
| `Priority: ...` header | `-F "type=info\|success\|warning\|failure"` form field |
| raw body | `-F "body=..."` form field |
| `Authorization: Bearer $NTFY_API_KEY` | (none; key-as-secret over tailscale) |

## 📚 Further Reading

- [Apprise wiki](https://github.com/caronc/apprise/wiki) — every URL format
- [apprise-api docs](https://github.com/caronc/apprise-api) — server-side API reference
- [Stateful mode](https://github.com/caronc/apprise-api#stateful-mode) — how keyed configs work
