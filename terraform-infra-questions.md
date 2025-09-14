# run terraform init in each environment folder ie. Prod and dev, so that it will create a .terrafrom and update it. don't run in each resource folder
# Differenciate with resource type or project type
# types of directories
    1) Separate root per environment (most common) # best if there is a difference between stag and prod
                                                   # auto sequencial creation of resource
                                                   # one s3 bucket with multiple keys
        infra/
            modules/
                vpc/
                eks/
                iam/
            envs/
                dev/
                    main.tf
                    versions.tf
                    backend.hcl
                    dev.tfvars
                stage/
                    main.tf
                    versions.tf
                    backend.hcl
                    stage.tfvars
                prod/
                    main.tf
                    versions.tf
                    backend.hcl
                    prod.tfvars
        cd infra/envs/dev
        terraform init -backend-config=backend.hcl
        terraform plan -var-file=dev.tfvars
        terraform apply

    2) Single root + .tfvars overlays per env # Best if both stag is equivalent to prod
                                              # auto sequencial creation of resource 
                                              # one s3 bucket with multple keys
                infra/
                    main.tf
                    variables.tf
                    versions.tf
                    backend.hcl
                envs/
                    dev.tfvars
                    stage.tfvars
                    prod.tfvars
        terraform plan -var-file=envs/dev.tfvars
        terraform apply -var-file=envs/dev.tfvars

    3) Single root + Terraform workspaces 
                infra/
                    main.tf
                    versions.tf
                    backend.hcl  # uses workspace key pattern
        terraform workspace select dev
        terraform plan -var-file=envs/dev.tfvars

    4) “Stacks” (by domain) + env overlays          # Manual sequencing  # one s3 bucket with multiple keys

            stacks/
                network/
                    modules/
                    envs/
                    dev/
                    prod/
                data/
                    modules/
                    envs/
                    dev/
                    prod/
                app/
                    modules/
                    envs/
                    dev/
                    prod/

For stack domain infra, we need to wire the details of service by state file and data code block
1. data query from another s3 bucket
2. upload the service data to ssm as resource call and pull with data code block
3. calls the aws api for the prod tag resource using data code block with filter function and attach them in existing resource

        ##Outputs + terraform_remote_state:##

        data "terraform_remote_state" "network" {
        backend = "s3"
        config = {
            bucket = "tf-state"
            key    = "network/prod.tfstate"
            region = "eu-west-1"
        }
        }

        module "eks" {
        source   = "../../modules/eks"
        subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
        }

        # Publish artifacts
        resource "aws_ssm_parameter" "vpc_id" {
        name  = "/platform/prod/network/vpc_id"
        type  = "String"
        value = module.vpc.vpc_id
        }

        data "aws_ssm_parameter" "vpc_id" {
        name = "/platform/prod/network/vpc_id"
        }
**Service discovery / lookups** (looser coupling): 
    Publish shared IDs to SSM Parameter Store or Secrets Manager, then read them.
