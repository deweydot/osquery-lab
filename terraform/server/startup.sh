#!/bin/bash

# Install docker compose and fleetctl
apt-get update
apt-get install -y docker.io docker-compose-v2 npm

# Set working directory
mkdir /etc/fleetdm
cd /etc/fleetdm
npm install -g fleetctl

# Create secret files
mkdir secrets
cat << 'EOF' > secrets/cert.pem
${cert_pem}
EOF
cat << 'EOF' > secrets/key.pem
${key_pem}
EOF
cat << 'EOF' > secrets/enroll_secret.yml
policies:
queries:
agent_options:
controls:
org_settings:
  secrets:
    - secret: "${enroll_secret}"
EOF

# Edit permissions
chmod 0444 secrets/cert.pem
chmod 0444 secrets/key.pem
chmod 0444 secrets/enroll_secret.yml

# Write docker compose file
cat << 'EOF' > docker-compose.yaml
${docker_compose}
EOF

# Run docker compose
systemctl enable docker
systemctl start docker
docker compose up -d

# Wait for server to be ready
until curl -k --fail 'https://localhost:8080/healthz'; do
  sleep 1
done

# Setup server
fleetctl config set --address 'https://localhost:8080' --tls-skip-verify >> log.txt
fleetctl setup\
  --email 'admin@pdx.edu'\
  --name 'admin'\
  --password '${admin_password}'\
  --org-name 'PSU' >> log.txt
fleetctl gitops -f secrets/enroll_secret.yml >> log.txt