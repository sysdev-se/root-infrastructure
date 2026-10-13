output "tf_state_bucket_name" {
  value       = google_storage_bucket.tf_state.name
  description = "Name of the Terraform state bucket."
}

output "tf_org_admin_service_account_email" {
  value       = data.google_service_account.tf_org_admin.email
  description = "Email of the org-level Terraform admin SA."
}

output "wif_provider_name" {
  value       = google_iam_workload_identity_pool_provider.github_actions.name
  description = "Resource name to use as workload_identity_provider in GitHub."
}

output "wif_pool_name" {
  value       = google_iam_workload_identity_pool.github.name
  description = "Workload identity pool; systems use it to let their app repos impersonate deploy SAs."
}

output "all_users_ingress_tag_value" {
  value       = google_tags_tag_value.allUsersIngressTrue.id
  description = "TagValue to bind to resources that must allow allUsers (see drs.tf)."
}

output "systems" {
  value = {
    for name, system in local.systems : name => {
      folder_id                 = google_folder.system[name].folder_id
      terraform_service_account = google_service_account.system_terraform[name].email
      state_bucket              = google_storage_bucket.system_tf_state[name].name
    }
  }
  description = "Per-system folder, Terraform SA and state bucket."
}
