locals {
  roles = {
    dev  = "arn:aws:iam::${var.aws_accounts["dev"]}:role/terraform-apply-role"
  }
  
  deploy_role = local.roles[terraform.workspace]
}