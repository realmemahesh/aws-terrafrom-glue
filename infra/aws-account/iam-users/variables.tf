variable "user_name" {
  description = "The name of the user to create"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
variable "path" {
  description = "The path for the user"
  type        = string
  default     = "/" 
}
variable "force_destroy" {
  description = "Whether to force destroy the user even if it has non-Terraform-managed IAM access keys, login profile or MFA devices"
    type        = bool
    default = false
}
