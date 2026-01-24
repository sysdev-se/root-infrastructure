output "tf_state_bucket_name" {
  value       = google_storage_bucket.tf_state.name
  description = "Name of the Terraform state bucket."
}

output "tf_org_admin_service_account_email" {
  value       = google_service_account.tf_org_admin.email
  description = "Email of the org-level Terraform admin SA."
}

output "wif_provider_name" {
  value       = google_iam_workload_identity_pool_provider.github_actions.name
  description = "Resource name to use as workload_identity_provider in GitHub."
}
