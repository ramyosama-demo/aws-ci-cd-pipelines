resource "aws_iam_role" "cw_events_role" {
  description = "CloudWatch Events Trigger Role - Managed by Terraform"
  tags        = var.tags

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "events.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "cw_events_role_policy_dev" {
  count = var.enable_dev == true ? 1 : 0
  role  = aws_iam_role.cw_events_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "codepipeline:StartPipelineExecution",
          "Resource" : aws_codepipeline.dev[0].arn
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "cw_events_role_policy_prod" {
  count = var.enable_prod == true ? 1 : 0
  role  = aws_iam_role.cw_events_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "codepipeline:StartPipelineExecution",
          "Resource" : aws_codepipeline.prod[0].arn
        }
      ]
    }
  )
}
