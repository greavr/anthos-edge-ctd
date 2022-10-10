# ----------------------------------------------------------------------------------------------------------------------
# Grafana Instance SA
# ----------------------------------------------------------------------------------------------------------------------
resource "google_service_account" "grafana-sa" {
    account_id   = "grafana-sa"
    display_name = "grafana-sa"
}

resource "google_project_iam_member" "grafana-sa-roles" {
    project = var.project_id
    for_each = toset(var.grafana-sa-roles)
    role    = "roles/${each.value}"
    member  = "serviceAccount:${google_service_account.grafana-sa.email}"
    depends_on = [
        google_service_account.grafana-sa
    ]
}