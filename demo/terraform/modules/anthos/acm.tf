# ----------------------------------------------------------------------------------------------------------------------
# Configure ACM Repo
# ----------------------------------------------------------------------------------------------------------------------
resource "google_gke_hub_feature" "acm" {
    provider = google-beta

    project  = var.project_id
    name = "configmanagement"
    location = "global"

    depends_on = [
        google_sourcerepo_repository.abm-config-sync
    ]
}