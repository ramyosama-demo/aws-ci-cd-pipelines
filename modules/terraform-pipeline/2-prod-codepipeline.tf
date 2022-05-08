#resource "aws_codestarconnections_connection" "example" {
#  name          = "example-connection"
#  provider_type = "GitHub"
#}

resource "aws_codepipeline" "prod" {
  count    = var.enable_prod == true ? 1 : 0
  name     = "${var.repository_name}-${var.custom_identifier}prod-tf"
  role_arn = aws_iam_role.codepipeline.arn
  tags     = var.tags

  artifact_store {
    location = data.aws_ssm_parameter.artifact_bucket.value
    type     = "S3"

    encryption_key {
      id   = data.aws_ssm_parameter.cmk_arn.value
      type = "KMS"
    }
  }

  stage {
    name = "clone"

    action {
      category         = "Source"
      name             = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["CodeWorkspace"]

      configuration = {
#        ConnectionArn    = aws_codestarconnections_connection.example.arn
#        FullRepositoryId = "${var.repo_owner}/${var.repository_name}"
        Owner                = var.repo_org
        Repo                 = var.repository_name
        Branch               = var.branch
        PollForSourceChanges = false  #Periodically check the location of your source content and run the pipeline if changes are detected
        OAuthToken           = data.aws_ssm_parameter.github_token.value
      }
    }
  }

  stage {
    name = "prod"

    action {
      run_order        = 1
      name             = "terraform-plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["CodeWorkspace"]
      output_artifacts = []
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.prod_plan[0].name
      }
    }

    action {
      run_order = 2
      name      = "devops-lead-approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
    }

    action {
      run_order = 2
      name      = "security-approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
    }


    action {
      run_order        = 3
      name             = "terraform-apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["CodeWorkspace"]
      output_artifacts = []
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.prod_apply[0].name
      }
    }
  }
}

resource "random_string" "github_secret" {
  length  = 99
  special = false
}

locals {
  webhook_secret = random_string.github_secret.result
}

resource "aws_codepipeline_webhook" "codepipeline_webhook" {
  name            = "test-webhook-github"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.prod[0].name

  authentication_configuration {
    secret_token = local.webhook_secret
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/${var.branch}"
  }
}
/*
resource "github_repository" "repo" {
  provider =  github
  name         = "aws-test-ci-cd"
  description  = "Terraform acceptance tests"

  private = false
}
*/
# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "github_webhook" {
  repository = "${var.repo_org}/${var.repository_name}"
#  repository = var.repository_name
#  provider =  github
#  repository = github_repository.repo.name
  events = ["push"]

  configuration {
    url          = aws_codepipeline_webhook.codepipeline_webhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = local.webhook_secret
  }

  lifecycle {
    # This is required for idempotency
    ignore_changes = [configuration[0].secret]
  }
}