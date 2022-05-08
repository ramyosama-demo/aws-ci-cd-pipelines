resource "aws_iam_role" "codebuild" {
  description = "CodeBuild Service Role - Managed by Terraform"
  tags        = var.tags

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "codebuild.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning",
            "s3:PutObject"
          ],
          "Resource" : [
            "arn:aws:s3:::${data.aws_ssm_parameter.artifact_bucket.value}",
            "arn:aws:s3:::${data.aws_ssm_parameter.artifact_bucket.value}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ],
          "Resource" : data.aws_ssm_parameter.cmk_arn.value
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:Get*",
            "s3:List*"
          ],
          "Resource" : [
            "arn:aws:s3:::${data.aws_ssm_parameter.remote_state_bucket.value}",
            "arn:aws:s3:::${data.aws_ssm_parameter.remote_state_bucket.value}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Resource" : "arn:aws:iam::*:role/${var.pipeline_role}"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : "arn:aws:s3:::${data.aws_ssm_parameter.remote_state_bucket.value}/${var.repository_name}/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:DeleteItem"
          ],
          "Resource" : data.aws_ssm_parameter.locks_table_arn.value
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}
