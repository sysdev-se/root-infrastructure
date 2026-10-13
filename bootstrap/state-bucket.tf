resource "google_storage_bucket" "tf_state" {
  name          = "sysdev-tfstate"
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
    # Only prune old noncurrent versions; live state files must never expire.
    condition {
      days_since_noncurrent_time = 365
    }
  }

  depends_on = [google_project_iam_member.tf_org_admin_storage_admin]
}
