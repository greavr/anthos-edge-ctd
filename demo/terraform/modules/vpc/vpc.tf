# ----------------------------------------------------------------------------------------------------------------------
# CREATE VPC & Subnets
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_network" "demo-vpc" {
  name = var.vpc-name            
  auto_create_subnetworks = false
}

resource "google_compute_router" "primary" {
  name    = "${var.region}-router"
  region  = "${var.region}"
  network = google_compute_network.demo-vpc.id

  bgp {
    asn = 64514
  }

  depends_on = [
    google_compute_network.demo-vpc
  ]
}
