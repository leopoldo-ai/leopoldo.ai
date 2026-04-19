---
name: terraform-iac
description: "Use when managing infrastructure with Terraform or OpenTofu. Covers module design, state management, CI/CD, and cloud provider patterns. OSS-first: OpenTofu primary, Terraform as standard. Triggers on: Terraform, OpenTofu, infrastructure as code, IaC, HCL, tfstate, terraform plan, terraform apply, modules."
type: technique
metadata:
  author: leopoldo
  source: https://github.com/antonbabenko/terraform-skill
  created: 2026-03-24
  forge_strategy: adapt
  forge_sources:
    - https://github.com/antonbabenko/terraform-skill
license: MIT
upstream:
  url: https://github.com/antonbabenko/terraform-skill
  version: main
  last_checked: 2026-03-24
---

# Terraform IaC -- Infrastructure as Code

## Why This Exists

| Problem | Solution |
|---------|----------|
| No infrastructure-as-code guidance in plugin | Terraform/OpenTofu patterns |
| Manual infrastructure management is error-prone | Declarative, version-controlled infra |

Adapted from [antonbabenko/terraform-skill](https://github.com/antonbabenko/terraform-skill).

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| OpenTofu (fully OSS fork) | Terraform Cloud |
| Terraform (BSL license) | Spacelift, env0 |

## Core Workflow

### 1. Project Structure

```
infrastructure/
  environments/
    dev/
      main.tf
      variables.tf
      terraform.tfvars
    staging/
    production/
  modules/
    networking/
    database/
    compute/
  backend.tf
```

### 2. Module Design

```hcl
# modules/database/main.tf
resource "aws_rds_instance" "main" {
  identifier     = "${var.project}-${var.environment}-db"
  engine         = "postgres"
  engine_version = var.postgres_version
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = var.environment == "production" ? 30 : 7
  multi_az               = var.environment == "production"

  tags = var.tags
}

# modules/database/variables.tf
variable "project" { type = string }
variable "environment" { type = string }
variable "instance_class" { type = string; default = "db.t3.micro" }
variable "postgres_version" { type = string; default = "16" }

# modules/database/outputs.tf
output "endpoint" { value = aws_rds_instance.main.endpoint }
output "db_name" { value = aws_rds_instance.main.db_name }
```

### 3. State Management

```hcl
# backend.tf - Remote state (S3 + DynamoDB)
terraform {
  backend "s3" {
    bucket         = "myproject-terraform-state"
    key            = "env/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
```

### 4. Workflow

```bash
terraform init         # Initialize providers and backend
terraform plan         # Preview changes (ALWAYS review before apply)
terraform apply        # Apply changes (requires confirmation)
terraform destroy      # Tear down (use with extreme caution)
```

## Rules

1. ALWAYS run `plan` before `apply` (review changes)
2. Remote state with locking (S3 + DynamoDB or equivalent)
3. Use modules for reusable components
4. Environment separation via workspaces or directories
5. Never store secrets in .tf files (use variables + secret manager)
6. Pin provider versions to avoid unexpected changes
7. Use `terraform fmt` and `terraform validate` in CI

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Local state file | Lost state = lost infra tracking | Remote state with locking |
| No plan before apply | Unreviewed changes to production | Always plan, review, then apply |
| Secrets in .tf files | Committed to version control | Variables + secret manager (Vault, AWS SSM) |
| One giant main.tf | Unmaintainable | Modules for logical grouping |
| No provider version pinning | Breaking updates | Pin with `required_providers` |
