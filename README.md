# 🚀 EGAD - Ephemeral GitHub Action Deployer (with Tailscale)

**EGAD** (Ephemeral GitHub Action Deployer) is a comprehensive guide and example implementation for secure, zero-trust deployment to Traefik reverse proxies via Tailscale using GitHub Actions.

## 🌐 Live Demo

Visit the interactive documentation: **[GitHub Pages Site](https://sntxrr.github.io/ephemeral-github-action-deployer/)**

## 🎯 What This Repository Demonstrates

**EGAD** (Ephemeral GitHub Action Deployer) showcases a **secure deployment pattern** that uses:

- **Ephemeral Tailscale nodes** for each deployment
- **Zero-trust networking** via Tailscale
- **GitHub Actions** for automated deployment
- **Traefik** as the reverse proxy
- **Docker Compose** for container orchestration

## 🔒 Security Benefits

- ✅ **No persistent credentials** stored in deployment environments
- ✅ **Zero public IP exposure** required
- ✅ **Automatic cleanup** of ephemeral nodes
- ✅ **Complete audit trail** through Tailscale and GitHub Actions
- ✅ **Zero-trust network access** with automatic authentication

## 📚 What You'll Find Here

### 1. **Interactive Documentation** (GitHub Pages)
- Comprehensive overview of the deployment pattern
- Step-by-step implementation guides
- Security architecture explanations
- Interactive code examples

### 2. **Complete Example Implementation**
- `examples/whoami-deployment/` - Full working example
- `examples/apprise-integration/` - Apprise notification setup
- Docker Compose configuration
- GitHub Actions workflow
- Traefik configuration
- Detailed setup instructions

### 3. **Reference Configurations**
- Traefik configuration files
- Docker Compose templates
- GitHub Actions workflows
- Security best practices
- Optional features and integrations
- Apprise notification system (multi-channel fan-out via apprise-api)

## 🚀 Quick Start

### Option 1: Use the Interactive Guide
1. Visit the [GitHub Pages site](https://sntxrr.github.io/ephemeral-github-action-deployer/)
2. Follow the interactive tabs and examples
3. Copy the configurations you need

### Option 2: Use the Example Implementation
1. Navigate to `examples/whoami-deployment/`
2. Follow the README instructions
3. Customize for your environment
4. Deploy!

## 🛠️ Prerequisites

- **Tailscale Network**: A Tailscale account and network
- **Traefik Server**: Server running Traefik v2+ with Docker
- **GitHub Repository**: For storing your deployment configurations
- **Domain Name**: For SSL certificates and routing

## 🔑 Required Secrets

Configure these in your GitHub repository:

| Secret | Description |
|--------|-------------|
| `TS_OAUTH_CLIENT_ID` | Tailscale OAuth client ID |
| `TS_OAUTH_SECRET` | Tailscale OAuth secret |
| `SSH_KEY` | SSH private key for server access |

## 📖 How It Works

1. **GitHub Actions Runner** creates an ephemeral Tailscale node
2. **Tailscale Network** provides secure, authenticated connection
3. **SSH over Tailscale** deploys to your target server
4. **Automatic cleanup** removes the ephemeral node
5. **Health checks** verify successful deployment



## 🔧 Development

### Local Development
```bash
npm install
npm run dev
```

### Build for Production
```bash
npm run build
```

### Deploy to GitHub Pages
```bash
npm run build
git add dist
git commit -m "Update site"
git push
```

## 📁 Repository Structure

```
.
├── src/                          # React application source
├── examples/                     # Working examples
│   └── whoami-deployment/       # Complete whoami example
├── .github/                      # GitHub Actions workflows
├── data/                         # Traefik configuration examples
├── scripts/                      # Deployment scripts
├── package.json                  # Node.js dependencies
├── vite.config.js               # Vite configuration
└── README.md                     # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `npm run dev`
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🆘 Support

- **Documentation**: Visit the [GitHub Pages site](https://sntxrr.github.io/ephemeral-github-action-deployer/)
- **Issues**: Open an issue in this repository
- **Examples**: Check the `examples/` directory for working implementations

## 🌟 Why EGAD?

Traditional deployment methods often require:
- Exposing servers to the public internet
- Storing long-lived credentials
- Complex firewall configurations
- Manual certificate management

**EGAD eliminates all of these issues** by leveraging Tailscale's zero-trust networking and ephemeral authentication.

---

**Built with ❤️ for secure, modern deployments with EGAD**