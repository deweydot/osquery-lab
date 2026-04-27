#!/bin/bash
set -e

# touch log file
date > terraform.log

# get current time
start_time=$(date +%s)

# terraform destroy
echo "Destroying level..."
if ! terraform -chdir="terraform/osquery" destroy -auto-approve -var-file="$PWD/terraform.tfvars" >> "terraform.log" 2>&1; then
    echo "Error: 'terraform destroy' failed. See terraform.log for details."
    exit 1
fi
echo "Level destroyed."

# calculate time elapsed
end_time=$(date +%s)
elapsed=$((end_time - start_time))
echo "Time elapsed: $elapsed seconds"