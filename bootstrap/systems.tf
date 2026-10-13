// systems.tf
// Every system (realestate, ...) gets its own folder, Terraform service account
// and state bucket. The system's infrastructure repo authenticates as that SA via
// WIF and can only manage projects inside its own folder.
//
// This is deliberately the bare minimum a system needs to bootstrap itself.
// Everything else (projects, networks, databases, services) belongs in the
// system's own repo.
//
// To add a system: add an entry below and merge, then give the infra repo the
// GCP_WIF_PROVIDER and GCP_TF_SERVICE_ACCOUNT secrets (see `terraform output systems`).

locals {
  systems = {
    realestate = {
      infra_repo = "realestate-infrastructure"
    }
  }

  # Roles each system's Terraform SA gets on its own folder.
  system_folder_roles = [
    "roles/owner",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.tagUser",
  ]

  system_folder_role_bindings = {
    for pair in setproduct(keys(local.systems), local.system_folder_roles) :
    "${pair[0]}/${pair[1]}" => { system = pair[0], role = pair[1] }
  }

  # People who get roles/editor on every system folder, so they can use the
  # console. Changes should still go through each system's infrastructure repo.
  system_editors = [
    "user:systemadmin@sysdev.se",
  ]

  system_editor_bindings = {
    for pair in setproduct(keys(local.systems), local.system_editors) :
    "${pair[0]}/${pair[1]}" => { system = pair[0], member = pair[1] }
  }
}

resource "google_folder" "system" {
  for_each = local.systems

  display_name = each.key
  parent       = "organizations/${var.org_id}"
}

resource "google_service_account" "system_terraform" {
  for_each = local.systems

  project      = var.bootstrap_project_id
  account_id   = "tf-${each.key}"
  display_name = "Terraform for the ${each.key} system"
}

resource "google_folder_iam_member" "system_terraform" {
  for_each = local.system_folder_role_bindings

  folder = google_folder.system[each.value.system].name
  role   = each.value.role
  member = "serviceAccount:${google_service_account.system_terraform[each.value.system].email}"
}

resource "google_folder_iam_member" "system_editor" {
  for_each = local.system_editor_bindings

  folder = google_folder.system[each.value.system].name
  role   = "roles/editor"
  member = each.value.member
}

# Lets the system link its projects to billing. Granted on the org because
# tf-org-admin may set org IAM but not billing account IAM; the billing account
# belongs to the org, so it inherits this. Linking still requires access to the
# project, which the SA only has inside its own folder.
resource "google_organization_iam_member" "system_terraform_billing_user" {
  for_each = local.systems

  org_id = var.org_id
  role   = "roles/billing.user"
  member = "serviceAccount:${google_service_account.system_terraform[each.key].email}"
}

# Needed to bind allUsersIngress=True to public services (see drs.tf).
resource "google_tags_tag_value_iam_member" "system_terraform_all_users_ingress" {
  for_each = local.systems

  tag_value = google_tags_tag_value.allUsersIngressTrue.name
  role      = "roles/resourcemanager.tagUser"
  member    = "serviceAccount:${google_service_account.system_terraform[each.key].email}"
}

# A dedicated state bucket keeps systems from reading each other's state.
resource "google_storage_bucket" "system_tf_state" {
  for_each = local.systems

  name          = "sysdev-tfstate-${each.key}"
  location      = var.default_region
  project       = var.bootstrap_project_id
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      days_since_noncurrent_time = 365
    }
  }

  depends_on = [google_project_iam_member.tf_org_admin_storage_admin]
}

resource "google_storage_bucket_iam_member" "system_tf_state" {
  for_each = local.systems

  bucket = google_storage_bucket.system_tf_state[each.key].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.system_terraform[each.key].email}"
}

resource "google_service_account_iam_member" "system_terraform_wif" {
  for_each = local.systems

  service_account_id = google_service_account.system_terraform[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/${each.value.infra_repo}"
}
