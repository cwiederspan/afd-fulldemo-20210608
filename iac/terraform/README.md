# Setup Up the Azure Resources

## Terraform Init

```bash

# Use remote storage
terraform init --backend-config ./backend-secrets.tfvars

```

## Terraform Plan and Apply

```bash

# Apply the script with the specified variable values
terraform apply \
-var 'base_name=cdw-afddemo-20210608' \
-var 'location=westus2' \
-var 'root_dns_name=afddemo.com'

#--var-file=secrets.tfvars

```
