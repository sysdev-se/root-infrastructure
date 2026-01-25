resource "google_tags_tag_key" "allUsersIngress" {
  parent     = "organizations/${var.org_id}"
  short_name = "allUsersIngress"
  description = "Marks resources that may allow allUsers/allAuthenticatedUsers."
}

resource "google_tags_tag_value" "allUsersIngressTrue" {
  parent     = "tagKeys/${google_tags_tag_key.allUsersIngress.name}"
  short_name = "True"
  description = "Allow public ingress for tagged resources."
}