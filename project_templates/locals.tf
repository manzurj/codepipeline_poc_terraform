locals {
  roles = {
    dev  = "arn:aws:iam::${var.aws_accounts["dev"]}:role/tf-codepipeline-deploy-role"
  }
  
  deploy_role = local.roles[terraform.workspace]
}