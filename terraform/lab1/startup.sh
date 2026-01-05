#!/bin/bash

# install osquery
wget -q "https://pkg.osquery.io/deb/osquery_5.20.0-1.linux_amd64.deb" -O /tmp/osquery.deb
dpkg -i /tmp/osquery.deb

# create enroll secret
echo "lab-secret" > /etc/osquery/enroll.secret

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

# start osqueryd
systemctl enable osqueryd
systemctl restart osqueryd