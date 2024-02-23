# Example flask app using Terraform
This will deploy a VM with flask installed onto GCP with network and firewall setup for SSH connection and requests to
flask

# Prerequisites
- gcloud CLI installed and configured
- IAM access to compute engine and network API
- Terraform installed

# Initialise local Terraform directory
1. `cd example-flask`
1. `terraform init`

# Plan Terraform deployment
This does all the prechecks for a deployment and shows a summary of changes to be made.
1. `terraform plan`

# Deploy Terraform
1. `terraform apply`
1. input "yes"

# Destroy all resources
1. `terraform destroy`