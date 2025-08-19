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
                <div key={index} className="component-card">
                  <div className="component-header">
                    <h4>{component.name}</h4>
                  </div>
                  
                  <p>{component.description}</p>
                  
                  <div className="component-config">
                    <h5>Configuration:</h5>
                    <pre><code>{component.config}</code></pre>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>


    </div>
  )
}

export default OptionalFeatures
