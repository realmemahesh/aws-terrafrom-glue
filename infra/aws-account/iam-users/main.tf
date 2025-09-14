module "aws_iam_user"  {
    source = "C:/Users/mahi9/Desktop/DevOps/aws/aws-glue/infra/modules/iam-user"
    user_name = var.user_name
    path = var.path
    force_destroy = var.force_destroy
    tags = var.tags
}