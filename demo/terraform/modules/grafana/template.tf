# ----------------------------------------------------------------------------------------------------------------------
# Grafana Instance Template
# ----------------------------------------------------------------------------------------------------------------------
# Create Instance template
resource "google_compute_instance_template" "grafana-template" {
    name        = "grafana-template"
    description = "This template is used to create Grafana Instance."

    tags = ["grafana"]

    instance_description = "Grafana Instance"
    machine_type         = var.instance-type
    can_ip_forward       = false

    scheduling {
        automatic_restart   = true
        on_host_maintenance = "MIGRATE"
    }

    // Create a new boot disk from an image
    disk {
        source_image = var.node-os
        auto_delete  = true
        boot         = true
    }

    network_interface {
        network = var.vpc-id
    }

    metadata_startup_script = "${file("${path.module}/scripts/startup.sh")}"

    service_account {
        email  =  google_service_account.grafana-sa.email
        scopes = ["cloud-platform"]
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_integrity_monitoring = true
    }

    depends_on = [
        google_service_account.grafana-sa
    ]
}