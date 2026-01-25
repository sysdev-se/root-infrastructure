resource "google_org_policy_policy" "domain_restricted_sharing" {
  name   = "organizations/${var.org_id}/policies/iam.allowedPolicyMemberDomains"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      condition {
        expression = "resource.matchTag('${var.org_id}/allUsersIngress', 'True')"
        title      = "Allow all identities for tagged resources"
      }

      allow_all = true
    }

    rules {
      condition {
        expression = "true"
        title      = "Default DRS rule"
      }

      values {
        allowed_values = [
          "sysdev.se",
        ]
      }
    }
  }
}