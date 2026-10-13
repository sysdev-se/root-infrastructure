# tf-org-admin and its org-level roles are created by ../bootstrap-org-billing,
# which is applied manually by an org admin. This root only references it.
data "google_service_account" "tf_org_admin" {
  project    = var.bootstrap_project_id
  account_id = "tf-org-admin"
}

# Both roots used to manage the SA and its tagAdmin binding. Forget them here
# without destroying anything; these blocks can be deleted after one apply.
removed {
  from = google_service_account.tf_org_admin
  lifecycle {
    destroy = false
  }
}

removed {
  from = google_organization_iam_member.tf_org_admin_tag_admin
  lifecycle {
    destroy = false
  }
}

resource "google_project_iam_member" "tf_org_admin_project_editor" {
  project = var.bootstrap_project_id
  role    = "roles/editor"
  member  = "serviceAccount:${data.google_service_account.tf_org_admin.email}"
}

# roles/editor can create buckets but not update them or change their IAM, which
# the state buckets (state-bucket.tf, systems.tf) need.
resource "google_project_iam_member" "tf_org_admin_storage_admin" {
  project = var.bootstrap_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${data.google_service_account.tf_org_admin.email}"
}

resource "google_project_iam_member" "tf_org_admin_artifact_registry_writer_dev" {
  project = "procv-dev-000001"
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${data.google_service_account.tf_org_admin.email}"
}

resource "google_project_iam_member" "tf_org_admin_wif_admin" {
  project = var.bootstrap_project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${data.google_service_account.tf_org_admin.email}"
}

resource "google_organization_iam_member" "tf_org_admin_tag_user" {
  org_id = var.org_id
  role   = "roles/resourcemanager.tagUser"
  member = "serviceAccount:${data.google_service_account.tf_org_admin.email}"
}

resource "google_organization_iam_member" "tf_org_admin_run_admin_org" {
  org_id = var.org_id
  role   = "roles/run.admin"
  member = "serviceAccount:${data.google_service_account.tf_org_admin.email}"
}

resource "google_project_iam_member" "tf_org_admin_sa_admin" {
  project = var.bootstrap_project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${data.google_service_account.tf_org_admin.email}"
}