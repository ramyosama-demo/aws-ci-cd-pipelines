resource "aws_codebuild_project" "dev_plan" {
  count          = var.enable_dev == true ? 1 : 0
  name           = "${var.repository_name}-dev-tf-plan"
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
      value = "DEV"
    }

    environment_variable {
      name  = "TF_ACTION"
      value = "plan"
    }

    environment_variable {
      name  = "TF_VAR_DEPLOY_ROLE"
      value = "arn:aws:iam::${var.dev_account_id}:role/${var.pipeline_role}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.build_spec
  }
}

resource "aws_codebuild_project" "dev_apply" {
  count          = var.enable_dev == true ? 1 : 0
  name           = "${var.repository_name}-dev-tf-apply"
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
      value = "DEV"
    }

    environment_variable {
      name  = "TF_ACTION"
      value = "apply -auto-approve"
    }

    environment_variable {
      name  = "TF_VAR_DEPLOY_ROLE"
      value = "arn:aws:iam::${var.dev_account_id}:role/${var.pipeline_role}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.build_spec
  }
}

resource "aws_iam_role_policy" "codepipeline_dev" {
  count = var.enable_dev == true ? 1 : 0
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
            aws_codebuild_project.dev_plan[0].arn,
            aws_codebuild_project.dev_apply[0].arn
          ]
        }
      ]
    }
  )
}
