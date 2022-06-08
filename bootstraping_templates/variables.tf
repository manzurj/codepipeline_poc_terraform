variable "aws_region" {
  type    = string
  default = ""
}

variable "aws_profile" {
  type    = string
  default = ""
}

variable "bucket_name" {
  type    = string
  default = ""
}

variable "table_name" {
  type    = string
  default = ""
}

/* Tags Variables */
#Use: tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-place-holder" }, )
variable "project-tags" {
  type = map(string)
  default = {
    Service    = "Terraform Bootstrap",
    DeployedBy = "example@mail.com"
  }
}

#Use: tags = { Name = "${var.name-prefix}-s3" }
variable "name-prefix" {
  type    = string
  default = "tfbootstrap"
}