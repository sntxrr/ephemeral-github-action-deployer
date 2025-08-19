import React, { useState, useEffect } from 'react'
import { Highlight, themes } from 'prism-react-renderer'

import OptionalFeatures from './components/OptionalFeatures'
import './App.css'

function App() {
  const [activeTab, setActiveTab] = useState('overview')
  const [theme, setTheme] = useState('light')

  useEffect(() => {
    // Check for saved theme preference or default to light
    const savedTheme = localStorage.getItem('egad-theme') || 'light'
    setTheme(savedTheme)
    document.documentElement.setAttribute('data-theme', savedTheme)
  }, [])

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light'
    setTheme(newTheme)
    localStorage.setItem('egad-theme', newTheme)
    document.documentElement.setAttribute('data-theme', newTheme)
  }

  const workflowYaml = `name: EGAD - Deploy to Traefik via Tailscale

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  TAILSCALE_HOST: "your-traefik-host"
  TAILSCALE_IP: "100.64.0.0"  # Your Tailscale IP
  TARGET_USER: "your-username"
  NOTIFY_TOPIC: "deployments"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Tailscale
        uses: tailscale/github-action@v2
        with:
          oauth-client-id: \${{ secrets.TS_OAUTH_CLIENT_ID }}
          oauth-secret: \${{ secrets.TS_OAUTH_SECRET }}
          tags: tag:ci
      
      - name: Setup SSH
        env:
          SSH_KEY: \${{ secrets.SSH_KEY }}
        run: |
          mkdir -p ~/.ssh
          echo "$SSH_KEY" > ~/.ssh/id_ed25519
          chmod 600 ~/.ssh/id_ed25519
          ssh-keyscan -H $TAILSCALE_HOST >> ~/.ssh/known_hosts
      
      - name: Deploy
        run: |
          ssh $TARGET_USER@$TAILSCALE_HOST "
            cd /path/to/your/app
            docker compose pull
            docker compose up -d
          "`

  const dockerComposeYaml = `version: '3.8'

services:
  whoami:
    image: traefik/whoami:v1.8.0
    container_name: whoami
    restart: unless-stopped
    networks:
      - web
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.entrypoints=https"
      - "traefik.http.routers.whoami.rule=Host(\`whoami.yourdomain.com\`)"
      - "traefik.http.routers.whoami.tls=true"
      - "traefik.http.routers.whoami.tls.certresolver=cloudflare"
      - "traefik.http.routers.whoami.service=whoami"
      - "traefik.http.services.whoami.loadbalancer.server.port=80"

networks:
  web:
    external: true`

  const traefikConfig = `# traefik.yml
api:
  dashboard: true
  debug: false

entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https
  https:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: web

certificatesResolvers:
  cloudflare:
    acme:
      email: your-email@domain.com
      storage: acme.json
      dnsChallenge:
        provider: cloudflare`

  const securityFeatures = [
    {
      title: "Ephemeral Authentication",
      description: "Each deployment creates a new, temporary Tailscale node that's automatically cleaned up after use.",
      icon: "🔐"
    },
    {
      title: "Zero Trust Network",
      description: "Leverages Tailscale's zero-trust networking for secure, authenticated connections.",
      icon: "🛡️"
    },
    {
      title: "No Persistent Credentials",
      description: "No long-lived SSH keys or credentials stored in the deployment environment.",
      icon: "🗝️"
    },
    {
      title: "Audit Trail",
      description: "Complete visibility into deployment activities through Tailscale logs and GitHub Actions.",
      icon: "📊"
    },
    {
      title: "Automatic Cleanup",
      description: "Ephemeral nodes are automatically removed after deployment completion.",
      icon: "🧹"
    }
  ]

  const tabs = [
    { id: 'overview', label: 'Overview', icon: '📖' },
    { id: 'workflow', label: 'GitHub Actions', icon: '⚡' },
    { id: 'docker', label: 'Docker Compose', icon: '🐳' },
    { id: 'traefik', label: 'Traefik Config', icon: '🌐' },
    { id: 'security', label: 'Security Features', icon: '🔒' },

    { id: 'optional', label: 'Optional Features', icon: '🚀' }
  ]

  return (
    <div className="app">
                      <header className="header">
                  <div className="container">
                    <div className="header-content">
                      <div className="header-text">
                        <h1>🚀 EGAD - Ephemeral GitHub Action Deployer</h1>
                        <p>EGAD - Secure, zero-trust deployment to Traefik reverse proxies via Tailscale</p>
                      </div>
                      <button 
                        className="theme-toggle" 
                        onClick={toggleTheme}
                        aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
                      >
                        {theme === 'light' ? '🌙' : '☀️'}
                      </button>
                    </div>
                  </div>
                </header>

      <main className="main">
        <div className="container">
          <div className="tabs">
            {tabs.map(tab => (
              <button
                key={tab.id}
                className={`tab ${activeTab === tab.id ? 'active' : ''}`}
                onClick={() => setActiveTab(tab.id)}
              >
                <span className="tab-icon">{tab.icon}</span>
                {tab.label}
              </button>
            ))}
          </div>

          <div className="tab-content">
            {activeTab === 'overview' && (
              <div className="overview">
                <h2>What is EGAD?</h2>
                <p>
                  EGAD (Ephemeral GitHub Action Deployer) demonstrates how to securely deploy applications to Traefik reverse proxies
                  running on your Tailscale network without storing persistent credentials or exposing
                  your infrastructure to the public internet.
                </p>
                
                <div className="features-grid">
                  {securityFeatures.map((feature, index) => (
                    <div key={index} className="feature-card">
                      <div className="feature-icon">{feature.icon}</div>
                      <h3>{feature.title}</h3>
                      <p>{feature.description}</p>
                    </div>
                  ))}
                </div>

                <div className="cta-section">
                  <h3>Ready to get started?</h3>
                  <p>Check out the implementation details in the tabs above, or check the <a href="https://github.com/sntxrr/ephemeral-github-action-deployer" target="_blank" rel="noopener noreferrer">Github repo</a>!</p>
                </div>
              </div>
            )}

            {activeTab === 'workflow' && (
              <div className="code-section">
                <h2>GitHub Actions Workflow</h2>
                <p>This workflow demonstrates the complete deployment process:</p>
                <Highlight
                  theme={themes.github}
                  code={workflowYaml}
                  language="yaml"
                >
                  {({ className, style, tokens, getLineProps, getTokenProps }) => (
                    <pre className={className} style={{ ...style, padding: '20px', overflowX: 'auto' }}>
                      {tokens.map((line, i) => (
                        <div key={i} {...getLineProps({ line, key: i })}>
                          {line.map((token, key) => (
                            <span key={key} {...getTokenProps({ token, key })} />
                          ))}
                        </div>
                      ))}
                    </pre>
                  )}
                </Highlight>
              </div>
            )}

            {activeTab === 'docker' && (
              <div className="code-section">
                <h2>Docker Compose Example</h2>
                <p>Example whoami service configuration for Traefik:</p>
                <Highlight
                  theme={themes.github}
                  code={dockerComposeYaml}
                  language="yaml"
                >
                  {({ className, style, tokens, getLineProps, getTokenProps }) => (
                    <pre className={className} style={{ ...style, padding: '20px', overflowX: 'auto' }}>
                      {tokens.map((line, i) => (
                        <div key={i} {...getLineProps({ line, key: i })}>
                          {line.map((token, key) => (
                            <span key={key} {...getTokenProps({ token, key })} />
                          ))}
                        </div>
                      ))}
                    </pre>
                  )}
                </Highlight>
              </div>
            )}

            {activeTab === 'traefik' && (
              <div className="code-section">
                <h2>Traefik Configuration</h2>
                <p>Basic Traefik configuration for the reverse proxy:</p>
                <Highlight
                  theme={themes.github}
                  code={traefikConfig}
                  language="yaml"
                >
                  {({ className, style, tokens, getLineProps, getTokenProps }) => (
                    <pre className={className} style={{ ...style, padding: '20px', overflowX: 'auto' }}>
                      {tokens.map((line, i) => (
                        <div key={i} {...getLineProps({ line, key: i })}>
                          {line.map((token, key) => (
                            <span key={key} {...getTokenProps({ token, key })} />
                          ))}
                        </div>
                      ))}
                    </pre>
                  )}
                </Highlight>
              </div>
            )}

            {activeTab === 'security' && (
              <div className="security-section">
                <h2>EGAD Security Architecture</h2>
                <div className="security-flow">
                  <div className="flow-step">
                    <div className="step-number">1</div>
                    <h3>GitHub Actions Runner</h3>
                    <p>Creates ephemeral Tailscale node with CI tag</p>
                  </div>
                  <div className="flow-arrow">→</div>
                  <div className="flow-step">
                    <div className="step-number">2</div>
                    <h3>Tailscale Network</h3>
                    <p>Secure, authenticated connection to target server</p>
                  </div>
                  <div className="flow-arrow">→</div>
                  <div className="flow-step">
                    <div className="step-number">3</div>
                    <h3>Target Server</h3>
                    <p>Deploy application via SSH over Tailscale</p>
                  </div>
                </div>
                
                <div className="security-benefits">
                  <h3>Key Benefits</h3>
                  <ul>
                    <li>No public IP exposure required</li>
                    <li>Automatic certificate management</li>
                    <li>Zero-trust network access</li>
                    <li>Ephemeral authentication</li>
                    <li>Complete audit trail</li>
                  </ul>
                </div>
              </div>
            )}



            {activeTab === 'optional' && (
              <OptionalFeatures />
            )}
          </div>
        </div>
      </main>

      <footer className="footer">
        <div className="container">
          <p>&copy; 2025 EGAD - Ephemeral GitHub Action Deployer. Built with ❤️ for secure deployments by <a href="https://sntxrr.link" target="_blank" rel="noopener noreferrer">sntxrr</a>.</p>
        </div>
      </footer>
    </div>
  )
}

export default App
