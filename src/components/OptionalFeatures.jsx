import React, { useState } from 'react'
import './OptionalFeatures.css'

const OptionalFeatures = () => {
  const [activeFeature, setActiveFeature] = useState('monitoring')

  const features = [
    {
      id: 'monitoring',
      title: '📊 Monitoring & Observability',
      icon: '📊',
      description: 'Advanced monitoring, logging, and observability features',
      components: [
        {
          name: 'Prometheus Metrics',
          description: 'Collect and expose metrics for monitoring',
          enabled: true,
          config: `# traefik.yml
metrics:
  prometheus:
    buckets:
      - 0.1
      - 0.3
      - 1.2
      - 5.0`
        },
        {
          name: 'Grafana Dashboards',
          description: 'Pre-built dashboards for EGAD deployments',
          enabled: true,
          config: `# docker-compose.yml
grafana:
  image: grafana/grafana:latest
  environment:
    - GF_SECURITY_ADMIN_PASSWORD=admin
  volumes:
    - ./grafana/dashboards:/etc/grafana/provisioning/dashboards`
        },

      ]
    },
    {
      id: 'security',
      title: '🔒 Enhanced Security',
      icon: '🔒',
      description: 'Additional security features and hardening',
      components: [
        {
          name: 'OAuth2 Authentication',
          description: 'Secure authentication for your applications',
          enabled: true,
          config: `# traefik.yml
http:
  middlewares:
    oauth2:
      forwardAuth:
        address: "http://oauth2-proxy:4180"
        trustForwardHeader: true`
        },
        {
          name: 'Rate Limiting',
          description: 'Protect against abuse and DDoS',
          enabled: true,
          config: `# traefik.yml
http:
  middlewares:
    rate-limit:
      rateLimit:
        burst: 100
        average: 50`
        },

      ]
    },
    {
      id: 'automation',
      title: '🤖 Automation & CI/CD',
      icon: '🤖',
      description: 'Advanced automation and deployment features',
      components: [
        {
          name: 'Auto-scaling',
          description: 'Automatic scaling based on metrics',
          enabled: true,
          config: `# docker-compose.yml
services:
  app:
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M`
        },


      ]
    },
    {
      id: 'integrations',
      title: '🔗 External Integrations',
      icon: '🔗',
      description: 'Integrations with external services and tools including notifications',
      components: [
        {
          name: 'Slack Notifications',
          description: 'Send deployment updates to Slack',
          enabled: true,
          config: `# In your workflow
- name: Notify Slack
  run: |
    curl -X POST -H 'Content-type: application/json' \\
         --data '{"text":"🚀 EGAD deployment successful!"}' \\
         \${{ secrets.SLACK_WEBHOOK_URL }}`
        },
        {
          name: 'NTFY Notifications',
          description: 'Real-time push notifications via NTFY',
          enabled: true,
          config: `# In your workflow
- name: Notify NTFY
  run: |
    curl -H "Title: 🚀 EGAD Deployment" \\
         -H "Priority: default" \\
         -H "Tags: rocket,deployment" \\
         -H "Authorization: Bearer \${{ secrets.NTFY_API_KEY }}" \\
         -d "Deployment successful for commit \${{ github.sha }}" \\
         \${{ secrets.NTFY_SERVER }}/\${{ secrets.NTFY_TOPIC }}`
        },


      ]
    }
  ]

  const toggleFeature = (featureId, componentIndex) => {
    const updatedFeatures = features.map(feature => {
      if (feature.id === featureId) {
        const updatedComponents = feature.components.map((component, index) => {
          if (index === componentIndex) {
            return { ...component, enabled: !component.enabled }
          }
          return component
        })
        return { ...feature, components: updatedComponents }
      }
      return feature
    })
    // In a real app, you'd save this to state or backend
    console.log('Feature toggled:', updatedFeatures)
  }

  return (
    <div className="optional-features">
      <h2>🚀 Optional Features & Integrations</h2>
      <p>
        EGAD comes with a rich ecosystem of optional features that you can enable
        based on your specific needs. These features enhance security, monitoring,
        and automation capabilities.
      </p>

      <div className="features-tabs">
        {features.map(feature => (
          <button
            key={feature.id}
            className={`feature-tab ${activeFeature === feature.id ? 'active' : ''}`}
            onClick={() => setActiveFeature(feature.id)}
          >
            <span className="feature-icon">{feature.icon}</span>
            {feature.title}
          </button>
        ))}
      </div>

      <div className="feature-content">
        {features.map(feature => (
          <div
            key={feature.id}
            className={`feature-panel ${activeFeature === feature.id ? 'active' : ''}`}
          >
            <div className="feature-header">
              <h3>{feature.title}</h3>
              <p>{feature.description}</p>
            </div>

            <div className="components-grid">
              {feature.components.map((component, index) => (
                <div key={index} className={`component-card ${component.enabled ? 'enabled' : 'disabled'}`}>
                  <div className="component-header">
                    <h4>{component.name}</h4>
                    <label className="toggle-switch">
                      <input
                        type="checkbox"
                        checked={component.enabled}
                        onChange={() => toggleFeature(feature.id, index)}
                      />
                      <span className="slider"></span>
                    </label>
                  </div>
                  
                  <p>{component.description}</p>
                  
                  {component.enabled && (
                    <div className="component-config">
                      <h5>Configuration:</h5>
                      <pre><code>{component.config}</code></pre>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>

      <div className="feature-summary">
        <h3>🎯 Feature Summary</h3>
        <div className="summary-grid">
          {features.map(feature => (
            <div key={feature.id} className="summary-card">
              <div className="summary-header">
                <span className="summary-icon">{feature.icon}</span>
                <h4>{feature.title.split(' ').slice(1).join(' ')}</h4>
              </div>
              <div className="summary-stats">
                <span className="enabled-count">
                  {feature.components.filter(c => c.enabled).length}
                </span>
                <span className="total-count">
                  / {feature.components.length}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

export default OptionalFeatures
