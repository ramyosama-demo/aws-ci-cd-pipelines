resource "aws_iam_role" "codepipeline" {
  description = "CodePipeline Service Role - Managed by Terraform"
  tags        = var.tags

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "codepipeline.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "codepipeline" {
  role = aws_iam_role.codepipeline.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetBucket*"
          ],
          "Resource" : "arn:aws:s3:::${data.aws_ssm_parameter.artifact_bucket.value}"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:*"
          ],
          "Resource" : "arn:aws:s3:::${data.aws_ssm_parameter.artifact_bucket.value}/*"
        },
        {
          "Action" : [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ],
          "Effect" : "Allow",
          "Resource" : data.aws_ssm_parameter.cmk_arn.value
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:PassRole",
          "Resource" : aws_iam_role.codebuild.arn
        },
        {
          "Effect" : "Allow",
          "Action" : "codestar-connections:*",
          "Resource" : "*"
        }
      ]
    }
  )
}
