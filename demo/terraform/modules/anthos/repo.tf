# ----------------------------------------------------------------------------------------------------------------------
# Configure ACM Repo
# ----------------------------------------------------------------------------------------------------------------------
resource "google_sourcerepo_repository" "abm-config-sync" {
    provider = google-beta

    name = "abm-config-sync"    
    project  = var.project_id

}