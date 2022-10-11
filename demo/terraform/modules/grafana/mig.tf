# ----------------------------------------------------------------------------------------------------------------------
# Managed Instance Group
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance_group_manager" "grafana-igm" {
  name = "grafana-igm"

  base_instance_name = "grafana"
  zone               = var.zone

  version {
    instance_template  = google_compute_instance_template.grafana-template.id
  }

  target_size  = 1

  named_port {
    name = "grafana"
    port = 3000
  }

  depends_on = [
    google_compute_instance_template.grafana-template
  ]
}

