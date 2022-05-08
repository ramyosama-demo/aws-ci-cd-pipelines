resource "aws_kms_key" "this" {
  description             = "Used to encrypt Pipeline S3 artifacts / Terraform remote state files"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  is_enabled              = true
  tags                    = local.common_tags

  lifecycle {
    prevent_destroy = true
  }

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Allow account admin of the key",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action" : "kms:*",
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_kms_alias" "this" {
  name          = "alias/${lower(var.PROJECT)}-ci-cd"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_ssm_parameter" "cmk_arn" {
  name  = "ci-cd-cmk-arn"
  type  = "String"
  value = aws_kms_key.this.arn
}