# List of regions (support for multi-region deployment)
variable "regions" { 
    type = list(object({
        region = string
        cidr = string
        zone = string
        })
    )
    default = [{
            region = "us-central1"
            cidr = "10.0.0.0/24"
            zone = "us-central1-a"
        },
        {
            region = "us-east1"
            cidr = "10.0.1.0/24"
            zone = "us-east1-b"
        },
        {
            region = "us-south1"
            cidr = "10.0.2.0/24"
            zone = "us-south1-a"
        },
        {
            region = "us-west1"
            cidr = "10.0.3.0/24"
            zone = "us-west1-a"
        },
        {
            region = "us-west2"
            cidr = "10.0.4.0/24"
            zone = "us-west2-a"
        },
        {
            region = "us-west3"
            cidr = "10.0.5.0/24"
            zone = "us-west3-a"
        },
        {
            region = "us-west4"
            cidr = "10.0.6.0/24"
            zone = "us-west4-a"
        },
        {
            region = "us-east4"
            cidr = "10.0.7.0/24"
            zone = "us-east4-a"
        },
        {
            region = "northamerica-northeast1"
            cidr = "10.0.8.0/24"
            zone = "northamerica-northeast1-a"
        },]
}

# Service to enable
variable "services_to_enable" {
    description = "List of GCP Services to enable"
    type    = list(string)
    default =  [
        "compute.googleapis.com",
        "iap.googleapis.com",
        "secretmanager.googleapis.com",
        "cloudbuild.googleapis.com",
        "composer.googleapis.com",
        "anthos.googleapis.com",
        "anthosaudit.googleapis.com",
        "anthosgke.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "container.googleapis.com",
        "gkeconnect.googleapis.com",
        "gkehub.googleapis.com",
        "iam.googleapis.com",
        "logging.googleapis.com",
        "monitoring.googleapis.com",
        "opsconfigmonitoring.googleapis.com",
        "serviceusage.googleapis.com",
        "stackdriver.googleapis.com",
        "servicemanagement.googleapis.com",
        "servicecontrol.googleapis.com",
        "storage.googleapis.com",
        "run.googleapis.com",
        "sourcerepo.googleapis.com",
        "anthosconfigmanagement.googleapis.com"
    ]
}

# Master Node Count
variable "master-node-count" {
    description = "# of Kubernetes master nodes"
    type = number
    default = 1
}

# Worker Node Cout
variable "min-worker-node-count" {
    description = "# of Kubernetes worker nodes"
    type = number
    default = 2
}

# Instance Type
variable "gce-instance-type" {
  description = "GCE Instance Spec"
  type = string
  default = "e2-standard-4"
}

# Instance OS
variable "gce-instance-os" {
    description = "GCE Instance OS"
    type = string
    default = "ubuntu-os-cloud/ubuntu-minimal-2004-lts"
  
}

# Storage Bucket
variable "gcs-bucket-name" {
    default = "abm-config"
    description = "Bucket used to store kubectl config and abm template"
    type = string
    }

# Firewall rules
variable "abm-firewall-ports-tcp" {
    description = "Ports required for abm"
    type = list(string)
    default = [ 
        "6444",
        "10250",
        "2379-2380",
        "10250-10252",
        "10256",
        "4240",
        "30000-32767",
        "7946",
        "443",
        "22"
        ]
  
}

variable "abm-firewall-ports-udp" {
    description = "Ports required for abm"
    type = list(string)
    default = [ 
        "6081",
        "7946"
        ]
  
}

# ----------------------------------------------------------------------------------------------------------------------
# CTD Required
# ----------------------------------------------------------------------------------------------------------------------
variable "project_id" {
  type        = string
  description = "project id required"
}
# variable "project_name" {
#  type        = string
#  description = "project name in which demo deploy"
# }
# variable "project_number" {
#  type        = string
#  description = "project number in which demo deploy"
# }
# variable "gcp_account_name" {
#  description = "user performing the demo"
# }
# variable "deployment_service_account_name" {
#  description = "Cloudbuild_Service_account having permission to deploy terraform resources"
# }
# variable "org_id" {
#  description = "Organization ID in which project created"
# }
# variable "data_location" {
#  type        = string
#  description = "Location of source data file in central bucket"
# }
# variable "secret_stored_project" {
#   type        = string
#   description = "Project where secret is accessing from"
# }