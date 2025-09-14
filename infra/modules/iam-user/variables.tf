variable "user_name" {
  description = "value for iam user name"
  type = string
}
variable "path"{
    description = "value for iam user path"
    type = string
    default = "/"
}
variable "force_destroy"{
    description = "value for iam user force_destroy"
    type = bool
    default = false
}

variable "tags" {
description = "value for iam user tags"
type = map(string)
default = {}
}