# ----------------------------------------------------------------------------------------------------------------------
# Main modules
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# Enable APIs
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_service" "enable-services" {
  for_each = toset(var.services_to_enable)

  project = var.project_id
  service = each.value
  disable_on_destroy = false
}

# ----------------------------------------------------------------------------------------------------------------------
# Generate SSH Key
# ----------------------------------------------------------------------------------------------------------------------
module "ssh-key" {
    source = "./modules/ssh-key"

    depends_on = [
        google_project_service.enable-services,
    ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Generate SAs
# ----------------------------------------------------------------------------------------------------------------------
module "abm-sa" {
    source = "./modules/abm_sa"
    project_id = var.project_id

    depends_on = [
        google_project_service.enable-services,
    ]
}

# ----------------------------------------------------------------------------------------------------------------------
# GCS For template files
# ----------------------------------------------------------------------------------------------------------------------
module "gcs" {
  source = "./modules/gcs"

  project_id = var.project_id
  gcs-bucket-name = var.gcs-bucket-name

  depends_on = [
    google_project_service.enable-services
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create VPC
# ----------------------------------------------------------------------------------------------------------------------
module "vpc" {
    source = "./modules/vpc"

    project_id = var.project_id
    region = var.regions[0].region
    vpc-name = "abm"
    firewall-ports-tcp = var.abm-firewall-ports-tcp
    firewall-ports-udp = var.abm-firewall-ports-udp

    depends_on = [
        google_project_service.enable-services,
    ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure Anthos
# ----------------------------------------------------------------------------------------------------------------------
module "anthos" {
  source = "./modules/anthos"

  project_id = var.project_id

  depends_on = [
    google_project_service.enable-services
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Build abm-clusters
# ----------------------------------------------------------------------------------------------------------------------
module "nodes" {
    source = "./modules/abm-cluster"

    for_each = {for a_subnet in var.regions: a_subnet.region => a_subnet}

    region = "${each.value.region}"
    cidr = "${each.value.cidr}"
    zone = "${each.value.zone}"
    vpc-name = module.vpc.vpc
    
    master-node-count = var.master-node-count
    min-worker-node-count = var.min-worker-node-count
    node-os = var.gce-instance-os
    node-spec = var.gce-instance-type
    
    project_id = var.project_id
    public-key = module.ssh-key.public-key
    vx-ip-master = 3
    vx-ip-worker = 4

    adm-node-sa = module.abm-sa.adm-node-sa
    abm-workstation-sa = module.abm-sa.abm-workstation-sa

    private-key = module.ssh-key.secret-name
    sa-key-list = module.abm-sa.secrets-list
    template-path = module.gcs.abm-template-file
    vx-ip = 2
    repo-url = module.anthos.source-repo

    gcs_bucket = module.gcs.gcs_bucket_name


    depends_on = [
      module.gcs,
      module.abm-sa,
      module.ssh-key,
      module.vpc
    ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure Grafana
# ----------------------------------------------------------------------------------------------------------------------
module "grafana" {
  source = "./modules/grafana"

  project_id = var.project_id
  node-os = var.gce-instance-os

  vpc-id = module.vpc.vpc
  zone = var.regions[0].zone
  region = var.regions[0].region

  depends_on = [
    google_project_service.enable-services
  ]
}

