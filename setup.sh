#!/bin/bash

# get inputs from user
read -p "Project ID: " PROJECT_ID
read -p "Region [us-west1]: " REGION
REGION=${REGION:-us-west1}
read -p "Zone [us-west1-b]: " ZONE
ZONE=${ZONE:-us-west1-b}

# write to terraform.tfvars
cat <<EOF > terraform.tfvars
project_id = "$PROJECT_ID"
region = "$REGION"
zone = "$ZONE"
EOF

# touch log file
date > terraform.log

# get current time
start_time=$(date +%s)

# enable required services
gcloud services enable \
    compute.googleapis.com \
    run.googleapis.com

# terraform init
echo "Initializing terraform..."
if ! terraform -chdir="terraform/setup" init -input=false >> "terraform.log" 2>&1; then 
    echo "Error: 'terraform init' failed. See terraform.log for details."
    exit 1
fi

# terraform apply
echo "Applying setup..."
if ! terraform -chdir="terraform/setup" apply -auto-approve -var-file="$PWD/terraform.tfvars" >> "terraform.log" 2>&1; then
    echo "Error: 'terraform apply' failed. See terraform.log for details."
    exit 1
fi
echo "Setup done!"

# calculate time elapsed
end_time=$(date +%s)
elapsed=$((end_time - start_time))
echo "Time elapsed: $elapsed seconds"