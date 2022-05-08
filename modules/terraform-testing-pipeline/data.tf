data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "artifact_bucket" {
  name = "artifact-bucket"
}

data "aws_ssm_parameter" "remote_state_bucket" {
  name = "tf-remote-state-bucket"
}

data "aws_ssm_parameter" "locks_table_arn" {
  name = "tf-locks-table-arn"
}

data "aws_ssm_parameter" "cmk_arn" {
  name = "ci-cd-cmk-arn"
}
