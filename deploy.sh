#!/bin/bash
set -e

# touch log file
date > terraform.log

# get current time
start_time=$(date +%s)

# terraform init
echo "Initializing terraform..."
if ! terraform -chdir="terraform/osquery" init -input=false >> "terraform.log" 2>&1; then 
    echo "Error: 'terraform init' failed. See terraform.log for details."
    exit 1
fi

# terraform apply
echo "Deploying level..."
if ! terraform -chdir="terraform/osquery" apply -auto-approve -var-file="$PWD/terraform.tfvars" >> "terraform.log" 2>&1; then
    echo "Error: 'terraform apply' failed. See terraform.log for details."
    exit 1
fi

# get terraform output
read -r password server <<< $(terraform -chdir=terraform/lab1 output -json | jq -r '[.admin_password.value, .external_ip.value] | join(" ")')

# wait for server to pass health check
echo "Waiting for server to be ready..."
until curl -k --fail "https://$server:8080/healthz" >/dev/null 2>&1; do
    sleep 2
done

# display info
echo "Server URL: https://$server:8080"
echo "Login with 'admin@pdx.edu' and '$password'"
echo "Level deployed!"

# calculate time elapsed
end_time=$(date +%s)
elapsed=$((end_time - start_time))
echo "Time elapsed: $elapsed seconds"