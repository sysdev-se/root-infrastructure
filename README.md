# root-infrastructure

Organization-level GCP resources for sysdev.se: everything that is shared by, or
sits above, the individual systems (procv, realestate, ...).

## Repository layout

Each system has an infrastructure repo (`<system>-infrastructure`) that declares its
environments, plus one repo per application (`<system>-api`, `<system>-web`, ...).
This repo gives each system a place to live and an identity to deploy with:

```
sysdev.se (organization)
├── root-infrastructure-485309   bootstrap project: Terraform SAs, WIF pool, state buckets
├── realestate/                   folder, managed by realestate-infrastructure as tf-realestate
│   └── realestate-prod-000001
└── procv-dev-000001              (predates folders; managed by procv-infrastructure as tf-org-admin)
```

## Terraform roots

### `bootstrap-org-billing/` (manual, local state)

Creates `tf-org-admin` and grants it its organization and billing roles. A service
account cannot grant these roles to itself, so an org admin applies this root by
hand. This only needs to happen once, when the org is first set up. Nothing else
should ever go here:

```sh
cd bootstrap-org-billing && terraform apply
```

Its state is the local `terraform.tfstate` file (gitignored). Keep a backup.

### `bootstrap/` (CI, state in `gs://sysdev-tfstate/bootstrap/root`)

Runs as `tf-org-admin`. It manages:

| File | Contents |
|---|---|
| `state-bucket.tf` | `sysdev-tfstate`, the shared state bucket (root and procv). |
| `wif.tf` | GitHub OIDC pool `github-pool`, restricted to the `sysdev-se` org, and the repos that may impersonate `tf-org-admin`. |
| `iam.tf` | Extra project-level roles for `tf-org-admin`. |
| `systems.tf` | The bare minimum per system: a folder, a Terraform SA (`tf-<system>`) with access to it, and a state bucket (`sysdev-tfstate-<system>`). |
| `org-tags.tf`, `drs.tf` | Domain restricted sharing: only sysdev.se identities may be granted access, except on resources tagged `allUsersIngress=True` (public Cloud Run services). |

PRs run `terraform plan`, and merging to `main` runs `terraform apply`
(`.github/workflows/terraform-bootstrap.yml`). Inputs come from repo secrets
(`TF_*`). For local runs, copy them into `bootstrap/terraform.tfvars`.

## Adding a system

1. Add it to `local.systems` in `bootstrap/systems.tf` and merge. CI applies it,
   so there's no local apply.
2. Create the `<system>-infrastructure` repo and give it these secrets:
   - `GCP_WIF_PROVIDER`: output `wif_provider_name`
   - `GCP_TF_SERVICE_ACCOUNT`: output `systems.<system>.terraform_service_account`
3. In that repo, create projects in the `systems.<system>.folder_id` folder, with
   state in the `systems.<system>.state_bucket` bucket. See realestate-infrastructure
   for the reference layout.

A system's SA is owner of its own folder and nothing else. Everything inside the
folder (projects, Cloud Run, SQL, deploy SAs for app repos) belongs in the system's
repo, not here.
