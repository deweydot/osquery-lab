#!/bin/bash

# install osquery
wget -O /etc/apt/keyrings/osquery.asc https://pkg.osquery.io/deb/pubkey.gpg
echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/osquery.asc] https://pkg.osquery.io/deb deb main' > /etc/apt/sources.list.d/osquery.list
apt update
apt install osquery -y

# configure osquery
cat <<EOF > /etc/osquery/osquery.flags
# remote settings
--config_plugin=tls
--distributed_plugin=tls
--tls_server_certs=/etc/ssl/certs/ca-certificates.crt
--enroll_secret_path=/etc/osquery/enroll.secret

# endpoints
--config_tls_endpoint=/config
--enroll_tls_endpoint=/enroll
--distributed_tls_read_endpoint=/distributed_read
--distributed_tls_write_endpoint=/distributed_write

# additional config
--tls_hostname=${server_hostname}
--disable_distributed=false
--distributed_interval=5
EOF

# write enroll secret
echo '${enroll_secret}' > /etc/osquery/enroll.secret

# start osqueryd
systemctl enable osqueryd
systemctl restart osqueryd