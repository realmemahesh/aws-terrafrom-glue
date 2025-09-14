output "user_name"{
  description = "value for iam user name"
  value = aws_iam_user.user_name.name
}
output "user_arn" {
  description = "value for iam user arn"
  value = aws_iam_user.user_name.arn
}
output "user_id" {
  description = "value for iam user id"
  value = aws_iam_user.user_name.id
}