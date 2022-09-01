# ----------------------------------------------------------------------------------------------------------------------
# ABM Workstation
# ----------------------------------------------------------------------------------------------------------------------
locals {
    master-node-ips = [
        for gce in google_compute_instance.masters: 
            gce.network_interface.0.network_ip
    ]

    worker-node-ips = [
        for gce in google_compute_instance.workers:
            gce.network_interface.0.network_ip
    ]

}

resource "google_compute_instance" "workstation" {
    name  = "abm-workstation-${var.region}"
    hostname  = "abm-workstation-${var.region}.${var.project_id}"
    machine_type = var.node-spec
    zone         = var.zone
    can_ip_forward = true
    allow_stopping_for_update = true


    tags = ["abm","abm-worker"]

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

    metadata_startup_script = "${file("${path.module}/scripts/abm-workstation.sh")}"

    metadata = {
        master-node-ips = join(",",local.master-node-ips),
        worker-node-ips = join(",",local.worker-node-ips),
        abm-private-key = var.private-key,
        sa-key-list = join(",",var.sa-key-list)
        ssh-keys = "ubuntu:${var.public-key}"
        template-path = var.template-path
        vx-ip = var.vx-ip
        repo-url = var.repo-url
        gcs-bucket = "gs://${var.gcs_bucket}"
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = var.abm-workstation-sa
        scopes = ["cloud-platform"]
    }
    
    depends_on = [
        google_compute_instance.masters,
        google_compute_instance.workers
    ]
}