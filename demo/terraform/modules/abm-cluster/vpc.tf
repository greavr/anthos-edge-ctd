# ----------------------------------------------------------------------------------------------------------------------
# CREATE VPC & Subnets
# ----------------------------------------------------------------------------------------------------------------------

resource "google_compute_network" "demo-vpc" {
  name = var.region                
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnets" {
  name = "${var.region}"
  ip_cidr_range =  "${var.cidr}"       
  region        = "${var.region}"
  network       = google_compute_network.demo-vpc.id
  depends_on = [
      google_compute_network.demo-vpc
    ]
}

resource "google_compute_router" "primary" {
  name    = "${var.region}-router"
  region  = "${var.region}"
  network = google_compute_network.demo-vpc.id

  bgp {
    asn = 64514
  }

  depends_on = [
    google_compute_subnetwork.subnets
  ]
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.region}-nat"
  router                             = google_compute_router.primary.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [
    google_compute_router.primary
  ]
}
