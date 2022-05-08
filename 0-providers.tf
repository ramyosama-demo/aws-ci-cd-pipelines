terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2" #* replace with target region which has the codecommit repos, do not change after first being set

#  profile = "default" #* set to name of local AWS CLI profile to be used for seed deployment, remove after seed deployment

  #! Uncomment assume_role block after seed deployment

    assume_role {
      role_arn = var.DEPLOY_ROLE
    }
}

provider "github" {
  token                = data.aws_ssm_parameter.github_token.value
  organization         = var.repo_org
  owner                = var.repo_owner
#  base_url             = var.github_base_url 
}