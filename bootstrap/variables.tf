variable "bootstrap_project_id" {
  type        = string
  description = "ID of the manually created bootstrap project (e.g. sysdev-bootstrap)."
}

variable "org_id" {
  type        = string
  description = "Numeric organization ID."
}

variable "google_workspace_customer_id" {
  description = "The google workspace customer id"
  type = string
}

variable "billing_account_id" {
  type        = string
  description = "Billing account ID (XXXXXX-XXXXXX-XXXXXX)."
}

variable "default_region" {
  type        = string
  description = "Default region for resources."
  default     = "europe-west1"
}

variable "github_org" {
  type        = string
  description = "GitHub organization/owner (e.g. sysdev-se)."
}

variable "infra_repos" {
  type        = list(string)
  description = "List of infra repos allowed to use WIF (e.g. [\"procv-infrastructure\",\"realestate-infrastructure\"])."
}
