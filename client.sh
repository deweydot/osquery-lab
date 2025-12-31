#!/bin/bash

SERVER_DOMAIN="heliochromic-herpetological-yi.ngrok-free.dev"

url="https://pkg.osquery.io/deb/osquery_5.20.0-1.linux_amd64.deb"
wget -q $url -O /tmp/osquery.deb
dpkg -i /tmp/osquery.deb

# ==========================================
# 2. CONFIGURE FLAGS
# ==========================================
echo "[*] Writing Configuration..."

touch /etc/osquery/enroll.secret
echo "lab-secret" > /etc/osquery/enroll.secret

touch /etc/osquery/osquery.flags
cat <<EOF > /etc/osquery/osquery.flags
# --- NETWORKING ---
--config_plugin=tls
--distributed_plugin=tls
--logger_plugin=tls
--tls_hostname=${SERVER_DOMAIN}
--enroll_secret_path=/etc/osquery/enroll.secret
--tls_server_certs=/etc/ssl/certs/ca-certificates.crt

# --- ENDPOINTS ---
--enroll_tls_endpoint=/enroll
--config_tls_endpoint=/config
--distributed_tls_read_endpoint=/distributed_read
--distributed_tls_write_endpoint=/distributed_write

# --- CONFIGURATION ---
--host_identifier=hostname
--distributed_interval=2
--logger_min_status=0
--disable_distributed=false
EOF

# ==========================================
# 3. START SERVICE
# ==========================================
echo "[*] Starting Osquery Agent..."
systemctl enable osqueryd
systemctl restart osqueryd

# ==========================================
# 4. VERIFICATION
# ==========================================
echo "------------------------------------------------"
echo " Setup Complete!"
echo "Target Server: ${SERVER_DOMAIN}"
echo "Hostname:      $(hostname)"
echo "------------------------------------------------"