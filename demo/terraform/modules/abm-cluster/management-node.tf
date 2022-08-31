# ----------------------------------------------------------------------------------------------------------------------
# Master Nodes
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "masters" {
    count = var.master-node-count
    name  = "abm-master-${var.region}-${count.index}"
    hostname = "abm-master-${var.region}-${count.index}.${var.project_id}"
    machine_type = var.node-spec
    zone         = var.zone
    can_ip_forward = true
    allow_stopping_for_update = true

    tags = ["abm","abm-master"]

    boot_disk {
        initialize_params {
            image = var.node-os
            size = 160
        }
    }

    network_interface {
        network = google_compute_network.demo-vpc.name
        subnetwork = google_compute_subnetwork.subnets.name
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_integrity_monitoring = true
    }

    metadata_startup_script = "${file("${path.module}/scripts/startup.sh")}"

    metadata = {
        ssh-keys = "ubuntu:${var.public-key}"
        vx-ip = var.vx-ip-master + count.index
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = var.adm-node-sa
        scopes = ["cloud-platform"]
    }

    depends_on = [
        google_compute_subnetwork.subnets
    ]
}
