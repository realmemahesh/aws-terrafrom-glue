resource "aws_iam_user" "user_name" {
  name = var.user_name
  path = var.path
  force_destroy = var.force_destroy
  tags = var.tags
}