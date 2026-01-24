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
    condition {
      age = 365
    }
  }
}
