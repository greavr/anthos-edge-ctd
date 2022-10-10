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

  all_instances_config {
  }

  target_pools = [google_compute_target_pool.grafana-template.id]
  target_size  = 1

  named_port {
    name = "grafana"
    port = 3000
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.Grafana.id
    initial_delay_sec = 300
  }

  depends_on = [
    google_compute_health_check.Grafana,
    google_compute_instance_template.grafana-template
  ]
}

