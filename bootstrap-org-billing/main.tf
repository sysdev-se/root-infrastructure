resource "google_service_account" "tf_org_admin" {
  account_id   = "tf-org-admin"
  display_name = "Terraform Org Admin / Project Creator"
  project      = var.bootstrap_project_id
}

resource "google_organization_iam_member" "tf_org_admin_project_creator" {
  org_id = var.org_id
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${google_service_account.tf_org_admin.email}"
}

resource "google_organization_iam_member" "tf_org_admin_folder_admin" {
  org_id = var.org_id
  role   = "roles/resourcemanager.folderAdmin"
  member = "serviceAccount:${google_service_account.tf_org_admin.email}"
}

resource "google_billing_account_iam_member" "tf_org_admin_billing_user" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.user"
  member             = "serviceAccount:${google_service_account.tf_org_admin.email}"
}
