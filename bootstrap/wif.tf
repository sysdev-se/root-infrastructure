resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "OIDC pool for GitHub Actions for sysdev-se repos."
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions Provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"     = "assertion.sub"
    "attribute.actor"    = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"      = "assertion.ref"
    "attribute.owner"        = "assertion.repository_owner"
  }

  attribute_condition = "attribute.owner == 'sysdev-se'"
}

locals {
  allowed_repos = [
    for r in var.infra_repos :
    "${var.github_org}/${r}"
  ]
}

resource "google_service_account_iam_member" "tf_org_admin_wif_bindings" {
  for_each = toset(local.allowed_repos)

  service_account_id = google_service_account.tf_org_admin.name
  role               = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${each.value}"
}

