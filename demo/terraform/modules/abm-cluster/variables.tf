# VPC Setip
variable "project_id" {}

variable "zone" {}
variable "region" {}
variable "cidr" {}

# Shared
variable "node-os" {}
variable "public-key" {}
variable "firewall-ports-tcp" {}
variable "firewall-ports-udp" {}

# ABM Nodes
variable "master-node-count" {}
variable "min-worker-node-count" {}
variable "node-spec" {}
variable "vx-ip-master" {}
variable "vx-ip-worker" {}
variable "adm-node-sa" {}


# ABM Workstation
variable "abm-workstation-sa" {}
variable "private-key" {}
variable "sa-key-list" {}
variable "template-path" {}
variable "vx-ip" {}
variable "repo-url" {}