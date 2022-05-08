resource "aws_codepipeline" "dev" {
  count    = var.enable_dev == true ? 1 : 0
  name     = "${var.repository_name}-${var.custom_identifier}dev-tf"
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
      output_artifacts = ["source_output"]

      configuration = {
        Owner                = var.repo_owner
        Repo                 = var.repo_name
        Branch               = var.branch
        PollForSourceChanges = false
        #        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "dev"

    action {
      run_order        = 1
      name             = "tflint"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["CodeWorkspace"]
      output_artifacts = []
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.dev_tflint[0].name
      }
    }

    action {
      run_order        = 2
      name             = "checkov"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["CodeWorkspace"]
      output_artifacts = []
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.dev_checkov[0].name
      }
    }
    action {
      run_order        = 3
      name             = "terraform-plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["CodeWorkspace"]
      output_artifacts = []
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.dev_plan[0].name
      }
    }

    action {
      run_order = 4
      name      = "devops-approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
    }

    action {
      run_order        = 5
      name             = "terraform-apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["CodeWorkspace"]
      output_artifacts = []
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.dev_apply[0].name
      }
    }
  }
}
