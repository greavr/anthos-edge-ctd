# ----------------------------------------------------------------------------------------------------------------------
# Grafana firewall Rules
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_firewall" "grafana-rules" {

    name = "public-grafana"
    network = var.vpc-id

    allow {
        protocol = "tcp"
        ports    = ["3000"]
    }

    target_tags = ["grafana"]

    source_ranges = [ "0.0.0.0/0"]

}