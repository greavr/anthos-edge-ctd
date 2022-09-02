# ----------------------------------------------------------------------------------------------------------------------
# Fleet Identity SA
# ----------------------------------------------------------------------------------------------------------------------
data "google_iam_policy" "fleet-identity-sa" {
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      "serviceAccount:${var.project_id}.svc.id.goog[config-management-system/root-reconciler]",
    ]
  }
}

resource "google_service_account" "fleet-identity-sa" {
    account_id   = "fleet-identity-sa"
    display_name = "fleet-identity-sa"
}

resource "google_service_account_iam_policy" "fleet-identity-sa-roles" {
    service_account_id = google_service_account.fleet-identity-sa.name
    policy_data        = data.google_iam_policy.fleet-identity-sa.policy_data
}
