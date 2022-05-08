resource "aws_codebuild_project" "prod_plan" {
  count          = var.enable_prod == true ? 1 : 0
  name           = "${var.repository_name}-prod-tf-plan"
  description    = "Managed using Terraform"
  service_role   = aws_iam_role.codebuild.arn
  encryption_key = data.aws_ssm_parameter.cmk_arn.value
  tags           = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = var.build_image
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "TF_VAR_ENV"
      value = "PROD"
    }

    environment_variable {
      name  = "TF_ACTION"
      value = "plan"
    }

    environment_variable {
      name  = "TF_VAR_DEPLOY_ROLE"
      value = "arn:aws:iam::${var.prod_account_id}:role/${var.pipeline_role}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.build_spec
  }
}


resource "aws_codebuild_project" "prod_tflint" {
  count          = var.enable_prod == true ? 1 : 0
  name           = "${var.repository_name}-prod-tflint"
  description    = "Managed using Terraform"
  service_role   = aws_iam_role.codebuild.arn
  encryption_key = data.aws_ssm_parameter.cmk_arn.value
  tags           = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = var.build_image
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "TF_VAR_ENV"
      value = "PROD"
    }
    environment_variable {
      name  = "TF_VAR_DEPLOY_ROLE"
      value = "arn:aws:iam::${var.prod_account_id}:role/${var.pipeline_role}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-tflint.yml"
  }
}

resource "aws_codebuild_project" "prod_checkov" {
  count          = var.enable_prod == true ? 1 : 0
  name           = "${var.repository_name}-prod-checkov"
  description    = "Managed using Terraform"
  service_role   = aws_iam_role.codebuild.arn
  encryption_key = data.aws_ssm_parameter.cmk_arn.value
  tags           = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = var.build_image
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "TF_VAR_ENV"
      value = "PROD"
    }
    environment_variable {
      name  = "TF_VAR_DEPLOY_ROLE"
      value = "arn:aws:iam::${var.prod_account_id}:role/${var.pipeline_role}"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-checkov.yml"
  }
}
resource "aws_codebuild_project" "prod_apply" {
  count          = var.enable_prod == true ? 1 : 0
  name           = "${var.repository_name}-prod-tf-apply"
  description    = "Managed using Terraform"
  service_role   = aws_iam_role.codebuild.arn
  encryption_key = data.aws_ssm_parameter.cmk_arn.value
  tags           = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = var.build_image
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "TF_VAR_ENV"
      value = "PROD"
    }

    environment_variable {
      name  = "TF_ACTION"
      value = "apply -auto-approve"
    }

    environment_variable {
      name  = "TF_VAR_DEPLOY_ROLE"
      value = "arn:aws:iam::${var.prod_account_id}:role/${var.pipeline_role}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.build_spec
  }
}

resource "aws_iam_role_policy" "codepipeline_prod" {
  count = var.enable_prod == true ? 1 : 0
  role  = aws_iam_role.codepipeline.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "codebuild:StartBuild",
            "codebuild:StopBuild",
            "codebuild:BatchGetBuilds"
          ],
          "Resource" : [
            aws_codebuild_project.prod_plan[0].arn,
            aws_codebuild_project.prod_tflint[0].arn,
            aws_codebuild_project.prod_checkov[0].arn,
            aws_codebuild_project.prod_apply[0].arn
          ]
        }
      ]
    }
  )
}
