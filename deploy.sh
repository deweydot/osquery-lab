#!/bin/bash

# parse flags
DESTROY=false
while getopts "d" opt; do
  case $opt in
    d)
        DESTROY=true
        ;;
  esac
done
shift $((OPTIND - 1))

# usage msg if arg not given
if [[ -z "$1" ]]; then
    echo "Usage: ./deploy.sh [-d] <level-name>"
    exit 1
fi

# touch log file
date > terraform.log

# terraform init
echo "Initializing terraform..."
if ! terraform -chdir="terraform/$1" init -input=false >> "terraform.log" 2>&1; then 
    echo "Error: 'terraform init' failed. See terraform.log for details."
    exit 1
fi

# terraform destroy
if $DESTROY; then
    echo "Destroying level..."
    if ! terraform -chdir="terraform/$1" destroy -auto-approve -var-file="$PWD/terraform.tfvars" >> "terraform.log" 2>&1; then
        echo "Error: 'terraform destroy' failed. See terraform.log for details."
        exit 1
    fi
    echo "Level destroyed."

# terraform apply
else
    echo "Deploying level..."
    if ! terraform -chdir="terraform/$1" apply -auto-approve -var-file="$PWD/terraform.tfvars" >> "terraform.log" 2>&1; then
        echo "Error: 'terraform apply' failed. See terraform.log for details."
        exit 1
    fi
    echo "Level deployed!"
fi