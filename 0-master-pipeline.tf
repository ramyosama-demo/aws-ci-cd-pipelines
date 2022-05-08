module "master_pipeline" {

  depends_on = [
    aws_s3_bucket.artifacts,
    aws_s3_bucket.remote_state,
    aws_kms_key.this,
    aws_dynamodb_table.locks_table
  ]

  source = "./modules/terraform-pipeline"

  repository_name = "aws-ci-cd-pipelines" #replace with final name of the repo where all pipelines will be defined
  tags            = local.common_tags
  enable_prod     = true
  prod_account_id = "901968315793" #replace with account which will host the codepipeline resources
  pipeline_role   = "ci-cd-deployment-role"
}
