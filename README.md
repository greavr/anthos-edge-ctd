# TEMPLATE

Requirement: **GCP PROJECT INTO WHICH TO DEPLOY**

# Tool Setup Guide

[Tool Install Guide](tools/ReadMe.md)

# Environment Setup
* Install tools
* Run the following commands to login to gcloud:
```
gcloud auth login
gcloud auth application-default login
```

This will setup your permissions for terraform to run.

# Deploy guide
```
cd terraform
terraform init
terraform plan
terraform apply
```


# Org Policy:
- **constraints/compute.vmCanIpForward** - Set To ***Not Enforces***
- **compute.disableNestedVirtualization** - Se To ***Not Enforces***
- **constraints/iam.disableServieAccountKeyCreation** - Set To ***Not Enforces***
- **constraints/run.allowedIngress** - Set To ***All***
- **constraints/run.allowedVPCEgress** - Set To ***All***
- **iam.allowedPolicyMemberDomains** - Set To ***All***
