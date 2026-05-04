#!/bin/bash

# install osquery
wget -O /etc/apt/keyrings/osquery.asc https://pkg.osquery.io/deb/pubkey.gpg
echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/osquery.asc] https://pkg.osquery.io/deb deb main' > /etc/apt/sources.list.d/osquery.list
apt update
apt install osquery -y

# configure osquery
cat <<EOF > /etc/osquery/osquery.flags
# server
--tls_hostname=${server_hostname}
--tls_server_certs=/etc/osquery/cert.pem

# enrollment
--host_identifier=instance
--enroll_secret_path=/etc/osquery/secret.txt
--enroll_tls_endpoint=/api/osquery/enroll

# config
--config_plugin=tls
--config_tls_endpoint=/api/v1/osquery/config
--config_refresh=10

# live query
--disable_distributed=false
--distributed_plugin=tls
--distributed_interval=10
--distributed_tls_max_attempts=3
--distributed_tls_read_endpoint=/api/v1/osquery/distributed/read
--distributed_tls_write_endpoint=/api/v1/osquery/distributed/write

# logging
--logger_plugin=tls
--logger_tls_endpoint=/api/v1/osquery/log
--logger_tls_period=10

# file carving
--disable_carver=false
--carver_start_endpoint=/api/v1/osquery/carve/begin
--carver_continue_endpoint=/api/v1/osquery/carve/block
--carver_block_size=8000000
EOF

# write secrets
echo '${server_cert}' > /etc/osquery/cert.pem
echo '${enroll_secret}' > /etc/osquery/secret.txt

# start osqueryd
systemctl enable osqueryd
systemctl restart osqueryd

# lab setup
cp /usr/bin/tail /tmp/blinky
/tmp/blinky -f /dev/null &
rm /tmp/blinky
nc -lk 6667 &
useradd -m alice
echo "alice:correcthorsebatterystaple" | chpasswd
chage -d 1999-12-31 alice