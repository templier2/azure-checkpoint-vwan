# Check Point CloudGuard IaaS Management Terraform deployment for Azure
Structure of a project
The basis of this configuration is a project on GitHub - https://github.com/CheckPointSW/CloudGuardIaaS/ (/terraform/azure)
Folder management-new-vnet is basis, it is taken as is.
Two other folders (high-availability-new-vnet and single-gateway-new-vnet) are merged and refactored to remove conflicts with same names. Single-gateway-new-net files have got a prefix "sgw-", high-availability files have got - "ha-".
All values were merged to the terraform.tfvars.

Note: default admin shell is changed to /bin/bash (it is needed for gateways' import).

After first deployment step mgmt_import_gw will fail.
You have to wait approx 20 minutes before running it again.

Update:
management network has become 10.0.0.0/22 (from /16) due to vWAN hub network 10.0.100.0/24