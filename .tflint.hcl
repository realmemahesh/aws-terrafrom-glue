#############################################
# TFLint root config – repo wide defaults  #
#############################################

# --- Core behavior ---
config {
  # Analyze modules (downloads external modules declared in source = "...").
  module                  = true
  # Don’t fail the run just because some modules can’t be fetched.
  force                   = false
  # Make rule severities matter (ERROR fails the run).
  # (Severities are set per rule below or by the ruleset defaults.)
  # You can also set --error-with-issues on CLI for CI jobs.
}

# --- Ignore junk paths (speed + signal) ---
# NOTE: patterns are glob-style and relative to this config.
ignore_paths = [
  "**/.terraform/**",
  "**/.git/**",
  "infra/tmp/**",
  "tools/**"
]

# --- Provider rulesets (PIN VERSIONS!) ---
plugin "aws" {
  enabled = true
  # Pin the ruleset version so CI is reproducible.
  version = ">= 0.38.0, < 0.39.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"

  # Optional: set a default region for type checks (instance types, AZs).
  # You can override per env with an env-specific config file (shown later).
  # region  = "eu-central-1"
}

#############################################
# Generic Terraform rules (provider-agnostic)
#############################################

# Enforce a required Terraform version in versions.tf
rule "terraform_required_version" {
  enabled  = true
  severity = "ERROR"
}

# Providers should be version-pinned (~> or exact)
rule "terraform_required_providers" {
  enabled  = true
  severity = "ERROR"
}

# Encourage standard module structure (main/vars/outputs)
rule "terraform_standard_module_structure" {
  enabled  = true
  severity = "WARNING"
}

# Module sources should be pinned (avoid floating main)
rule "terraform_module_pinned_source" {
  enabled  = true
  severity = "ERROR"
}

# Variables should have types
rule "terraform_typed_variables" {
  enabled  = true
  severity = "WARNING"
}

#############################################
# Example AWS rules (enable/disable/tune)
#############################################

# The exact rule names depend on the ruleset version.
# Run: `tflint --list-rules` to see the names in your setup.
# Below are patterns you typically want enforced.

# EC2 instance type must exist in region / family valid
rule "aws_instance_invalid_type" {
  enabled  = true
  severity = "ERROR"
}

# Security Group rules: invalid or overly broad CIDRs
rule "aws_security_group_invalid_cidr_blocks" {
  enabled  = true
  severity = "ERROR"
}

# S3: block public ACLs
rule "aws_s3_bucket_public_acls" {
  enabled  = true
  severity = "ERROR"
}

# S3: enforce bucket versioning (common best practice)
rule "aws_s3_bucket_versioning" {
  enabled  = true
  severity = "WARNING"
}

# RDS: storage/encryption sanity
rule "aws_db_instance_backup_retention_period" {
  enabled  = true
  severity = "WARNING"
}
rule "aws_db_instance_storage_encrypted" {
  enabled  = true
  severity = "ERROR"
}

# EBS: encryption on by default
rule "aws_ebs_volume_encrypted" {
  enabled  = true
  severity = "ERROR"
}

# IAM: avoid wildcard actions (coarse, but useful)
rule "aws_iam_policy_document_s3_wildcards" {
  enabled  = false # Example of disabling a noisy rule
}

#############################################
# Ignoring external modules (optional)
#############################################

# If you vendor or fetch external modules you trust and want to skip:
# ignore_module {
#   source = "terraform-aws-modules/vpc/aws"
# }
