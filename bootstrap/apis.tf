resource "google_project_service" "org_policy_api" {
  project = var.bootstrap_project_id
  service = "orgpolicy.googleapis.com"

  disable_on_destroy = false
}
