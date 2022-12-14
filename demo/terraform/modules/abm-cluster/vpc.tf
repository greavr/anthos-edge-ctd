# ----------------------------------------------------------------------------------------------------------------------
# CREATE VPC & Subnets
# ----------------------------------------------------------------------------------------------------------------------

resource "google_compute_subnetwork" "subnets" {
  name = "${var.region}"
  ip_cidr_range =  "${var.cidr}"       
  region        = "${var.region}"
  network       = var.vpc-name
}

