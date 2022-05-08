data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "github_token" {
  name = "github-token"
}