# ----------------------------------------------------------------------------------------------------------------------
# Firewall Rules
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_firewall" "abm-rules" {

    name = "allow-abm-talk-${google_compute_network.demo-vpc.name}"
    network = google_compute_network.demo-vpc.name

    allow {
        protocol = "all"
    }

    source_tags = ["abm"]
    target_tags = ["abm"]

    depends_on = [
        google_compute_network.demo-vpc
        ]
}

# ----------------------------------------------------------------------------------------------------------------------
# IAP Firewall Rule
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_firewall" "iap" {
    name    = "allow-iap-ssh-${google_compute_network.demo-vpc.name}"
    network = google_compute_network.demo-vpc.name


    allow {
        protocol = "tcp"
        ports    = ["22"]
    }

    source_ranges = ["35.235.240.0/20"]

    depends_on = [
        google_compute_network.demo-vpc
        ]
}
