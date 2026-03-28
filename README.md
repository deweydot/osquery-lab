# To Deploy

1. Add your project ID to the variables file.\
`nano terraform.tfvars`

2. Enable the required services.\
`gcloud services enable compute.googleapis.com`

3. Run the deploy script.\
`./deploy.sh lab1`

Deployment takes ~5 minutes.