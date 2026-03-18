#!/bin/bash

# Install docker compose
apt-get update
apt-get install -y docker.io docker-compose-v2

# Create secret files
mkdir -p /opt/app/secrets
cat << 'EOF' > /opt/app/secrets/cert.pem
${cert_pem}
EOF
cat << 'EOF' > /opt/app/secrets/key.pem
${key_pem}
EOF
cat << 'EOF' > /opt/app/secrets/enroll_secret.yml
apiVersion: v1
  kind: config
  spec:
    secrets:
      - secret: "${enroll_secret}"
EOF

# Edit permissions
chmod 0444 /opt/app/secrets/cert.pem
chmod 0444 /opt/app/secrets/key.pem
chmod 0444 /opt/app/secrets/enroll_secret.yml

# Write docker compose file
cat << 'EOF' > /opt/app/docker-compose.yaml
${docker_compose}
EOF

# Run docker compose
systemctl enable docker
systemctl start docker
cd /opt/app
docker compose up -d