#logging
resource "aws_s3_bucket" "logging" {
  bucket = "${lower(var.PROJECT)}-logging-${random_string.random_suffix.result}"
  acl    = "log-delivery-write"

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "s3Public_logging" {
  bucket                  = aws_s3_bucket.logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "logging" {
  bucket = aws_s3_bucket.logging.id

  policy = jsonencode(
    {
      "Version" : "2008-10-17",
      "Statement" : [
        {
          "Sid" : "DenyInsecureAccess",
          "Effect" : "Deny",
          "Principal" : "*",
          "Action" : "s3:*",
          "Resource" : [
            aws_s3_bucket.logging.arn,
            "${aws_s3_bucket.logging.arn}/*"
          ],
          "Condition" : {
            "Bool" : {
              "aws:SecureTransport" : "false"
            }
          }
        }
      ]
    }
  )
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${lower(var.PROJECT)}-artifacts-${random_string.random_suffix.result}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.this.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.logging.id
    target_prefix = "s3-access-logs/${lower(var.PROJECT)}-artifacts/"
  }

  lifecycle_rule {
    id      = "manage-old-objects"
    enabled = true

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      days = 90
    }
  }

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "s3Public_artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  policy = jsonencode(
    {
      "Version" : "2008-10-17",
      "Statement" : [
        {
          "Sid" : "DenyInsecureAccess",
          "Effect" : "Deny",
          "Principal" : "*",
          "Action" : "s3:*",
          "Resource" : [
            aws_s3_bucket.artifacts.arn,
            "${aws_s3_bucket.artifacts.arn}/*"
          ],
          "Condition" : {
            "Bool" : {
              "aws:SecureTransport" : "false"
            }
          }
        }
      ]
    }
  )
}

resource "aws_s3_bucket" "remote_state" {
  bucket = "${lower(var.PROJECT)}-tf-remote-state-${random_string.random_suffix.result}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.this.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.logging.id
    target_prefix = "s3-access-logs/${lower(var.PROJECT)}-tf-remote-state/"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "s3Public_remote_state" {
  bucket                  = aws_s3_bucket.remote_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id

  policy = jsonencode(
    {
      "Version" : "2008-10-17",
      "Statement" : [
        {
          "Sid" : "DenyInsecureAccess",
          "Effect" : "Deny",
          "Principal" : "*",
          "Action" : "s3:*",
          "Resource" : [
            aws_s3_bucket.remote_state.arn,
            "${aws_s3_bucket.remote_state.arn}/*"
          ],
          "Condition" : {
            "Bool" : {
              "aws:SecureTransport" : "false"
            }
          }
        },
        {
          "Sid" : "EnforceEncryption",
          "Effect" : "Deny",
          "Principal" : "*",
          "Action" : "s3:PutObject",
          "Resource" : [
            "${aws_s3_bucket.remote_state.arn}/*"
          ],
          "Condition" : {
            "StringNotEquals" : {
              "s3:x-amz-server-side-encryption" : "aws:kms"
            }
          }
        }
      ]
    }
  )
}

resource "aws_ssm_parameter" "remote_state_bucket" {
  name  = "tf-remote-state-bucket"
  type  = "String"
  value = aws_s3_bucket.remote_state.id
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "artifacts_bucket" {
  name  = "artifact-bucket"
  type  = "String"
  value = aws_s3_bucket.artifacts.id
  tags  = local.common_tags
}

# Random suffix
resource "random_string" "random_suffix" {
  length           = 10
  special          = false
  upper            = false
  min_numeric      = 3
  override_special = ".-"
}