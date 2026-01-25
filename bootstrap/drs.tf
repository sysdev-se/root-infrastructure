resource "google_org_policy_policy" "domain_restricted_sharing" {
  name   = "organizations/${var.org_id}/policies/iam.managed.allowedPolicyMembers"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      condition {
        expression = "resource.matchTag('${var.org_id}/allUsersIngress', 'True')"
        title      = "Allow all identities for tagged resources"
      }

      enforce = false
    }

    rules {
      condition {
        expression = "true"
        title      = "Default DRS rule"
      }

      enforce = true

      parameters {
        allowed_principal_sets = [
          "principalSet://cloudresourcemanager.googleapis.com/organizations/${var.org_id}",
        ]
      }
    }
  }
}
