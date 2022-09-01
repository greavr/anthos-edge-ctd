# ----------------------------------------------------------------------------------------------------------------------
# Edge API Server SA
# ----------------------------------------------------------------------------------------------------------------------
resource "google_service_account" "edge-api-sa" {
    account_id   = var.sa-name
    display_name = var.sa-name
}

resource "google_project_iam_member" "edge-api-sa-roles" {
    for_each = toset(var.api-sa-roles)
    role    = "roles/${each.value}"
    member  = "serviceAccount:${google_service_account.edge-api-sa.email}"
    depends_on = [
        google_service_account.edge-api-sa
    ]
}
