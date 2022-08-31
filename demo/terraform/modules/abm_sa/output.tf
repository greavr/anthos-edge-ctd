output "secrets-list" {
    value = [
        google_secret_manager_secret.connect-agent-key.secret_id, 
        google_secret_manager_secret.connect-register-key.secret_id, 
        google_secret_manager_secret.logging-sa-key.secret_id,
        google_secret_manager_secret.storage-sa-key.secret_id,
        ]
}

output "adm-node-sa" {
    value = google_service_account.abm-node-sa.email
}

output "abm-workstation-sa" {
    value = google_service_account.abm-workstation-sa.email
}