resource "google_service_account" "tf_org_admin" {
  account_id   = "tf-org-admin"
  display_name = "Terraform Org Admin / Project Creator"
  project      = var.bootstrap_project_id
}

resource "google_project_iam_member" "tf_org_admin_project_editor" {
  project = var.bootstrap_project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.tf_org_admin.email}"
}

resource "google_project_iam_member" "tf_org_admin_wif_admin" {
  project = var.bootstrap_project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${google_service_account.tf_org_admin.email}"
}

resource "google_organization_iam_member" "tf_org_admin_tag_admin" {
  org_id = var.org_id
  role   = "roles/resourcemanager.tagAdmin"
  member = "serviceAccount:${google_service_account.tf_org_admin.email}"
}
