#############################
1. create modules folder for the aws services
2. create env folder for each environment
3. terraform manifests  
    a. version.tf    # at root directory (common for all the environments)
    b. provider.tf   # seperate for each environment (DEV, PROD)
    c. main.tf
    d. backend.tf
    e. variables.tf
    f. terraform.tfvars
#############################
QUICK start commands

cd infra/envs/dev
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

#############################
BEST PRACTICES

1) Repo & folder structure (by environment + modules)
```text
        infra/
        ├─ modules/
        │  ├─ vpc/
        │  │  ├─ main.tf  ├─ variables.tf  ├─ outputs.tf  ├─ README.md  └─ examples/
        │  ├─ eks/
        │  └─ rds/
        ├─ envs/
        │  ├─ dev/
        │  │  ├─ main.tf
        │  │  ├─ providers.tf
        │  │  ├─ variables.tf
        │  │  ├─ terraform.tfvars        # dev values only
        │  │  └─ backend.hcl             # remote state config (no secrets)
        │  ├─ stage/
        │  └─ prod/
        ├─ versions.tf                   # required versions/providers
        ├─ .terraform.lock.hcl           # COMMIT this
        ├─ .gitignore                    # ignore *.tfstate, *.tfvars(secret)
        ├─ Makefile / taskfile           # fmt/validate/plan/apply targets
        └─ README.md

2) Remote state, locking, and encryption
        envs/prod/backend.hcl

        bucket         = "my-tfstate-prod"
        key            = "prod/terraform.tfstate"
        region         = "eu-central-1"
        dynamodb_table = "tf-locks-prod"   # enables state locking
        encrypt        = true


        envs/prod/providers.tf

        terraform {
        backend "s3" {}
        }
        provider "aws" {
        region = "eu-central-1"
        # assume role per env if needed:
        # assume_role { role_arn = "arn:aws:iam::123456789012:role/terraform-prod" }
        }
        Separate state per env/region/workload to reduce blast radius.
        S3 bucket: versioning + default encryption + block public access.
        Locking via DynamoDB.
        Never commit state or secrets.

3) Versions & pinning
        versions.tf

        terraform {
        required_version = "~> 1.9.0"
        required_providers {
            aws = { source = "hashicorp/aws", version = "~> 5.56" }
        }
        }


        Commit .terraform.lock.hcl.

        Pin providers with ~> constraints to prevent surprise upgrades.

4) Variables, typing, validation, and outputs
        variables.tf

        variable "project" {
        type        = string
        description = "Project name for tagging"
        validation {
            condition     = length(var.project) > 2
            error_message = "project must be > 2 chars."
        }
        }

        variable "private_subnet_cidrs" {
        type = list(string)
        }


        outputs.tf

        output "vpc_id"          { value = module.vpc.vpc_id }
        output "private_subnets" { value = module.vpc.private_subnets }


        Tips

        Give types for every variable; prefer object(...)/map(...) for structured input.

        Use nullable = false where appropriate.

        Only output what consumers need (outputs are visible to anyone with state access).

5) Modules: design & usage
        envs/prod/main.tf

        module "vpc" {
        source  = "../../modules/vpc"
        name    = "${var.project}-prod"
        cidr    = "10.0.0.0/16"
        az_count = 3
        }

        module "eks" {
        source = "../../modules/eks"
        vpc_id = module.vpc.vpc_id
        subnets = module.vpc.private_subnets
        cluster_name = "${var.project}-prod"
        }


        Module best practices

        Keep inputs minimal, outputs useful.

        Provide an examples/ folder and a README.md with inputs/outputs.

        Prefer for_each (stable addressing) over count when resources are keyed.

        Avoid heavy depends_on; rely on data flow through variables/outputs.

6) Tagging, naming, and immutability
        Standardize tags:

        locals {
        common_tags = {
            Project   = var.project
            Env       = var.env
            Owner     = var.owner
            ManagedBy = "Terraform"
        }
        }
        resource "aws_vpc" "this" {
        # ...
        tags = merge(local.common_tags, { Name = "${var.project}-${var.env}-vpc" })
        }


        Resource names should be predictable and stable to avoid destroy/recreate.

        Don’t bake environment names into modules; pass them via variables.
7) Security & secrets
        Never commit secrets. Use:

        AWS SSM Parameter Store / Secrets Manager, Vault, or CI secret store.

        Pass secret values via environment (e.g., TF_VAR_db_password).

        KMS-encrypt S3 state; encrypt RDS/EBS; restrict IAM to least-privilege.

        Use separate IAM roles per environment for Terraform runs.

8) CI/CD & quality gates
        Pre-commit hooks:

        terraform fmt -check

        terraform validate

        tflint (lint)

        tfsec / checkov (security)

        In PRs: run terraform plan and post the plan as a comment.

        Require review on any plan that includes destroy actions.

        Example Makefile:

        fmt:       ; terraform fmt -recursive
        validate:  ; terraform validate
        plan:      ; terraform plan -var-file=terraform.tfvars
        apply:     ; terraform apply -auto-approve -var-file=terraform.tfvars

9) Drift, imports, and lifecycle
        Periodically run terraform plan (or scheduled in CI) to detect drift.

        When adopting existing resources: terraform import then align attributes.

        Use lifecycle { prevent_destroy = true } only on critical resources (DBs).

        Be careful with ignore_changes—helpful for fields managed by external systems, but don’t overuse.

10) Workspaces vs folders
        Prefer separate folders/states per env (envs/dev, envs/prod).

        Workspaces are ok for small variations, but become hard to manage at scale.