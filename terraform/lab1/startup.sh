#!/bin/bash

# install osquery
wget -q "https://pkg.osquery.io/deb/osquery_5.20.0-1.linux_amd64.deb" -O /tmp/osquery.deb
dpkg -i /tmp/osquery.deb

# configure osquery
echo "lab-secret" > /etc/osquery/enroll.secret # server ignores this secret
cat <<EOF > /etc/osquery/osquery.flags
# networking
--config_plugin=tls
--distributed_plugin=tls
--logger_plugin=tls
--tls_hostname=${server_url}
--enroll_secret_path=/etc/osquery/enroll.secret
--tls_server_certs=/etc/ssl/certs/ca-certificates.crt

# endpoints
--enroll_tls_endpoint=/enroll
--config_tls_endpoint=/config
--distributed_tls_read_endpoint=/distributed_read
--distributed_tls_write_endpoint=/distributed_write

# additional config
--host_identifier=hostname
--distributed_interval=2
--logger_min_status=0
--disable_distributed=false
EOF

# start osqueryd
systemctl enable osqueryd
systemctl restart osqueryd