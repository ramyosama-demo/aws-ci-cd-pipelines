resource "aws_dynamodb_table" "locks_table" {
  name           = "${lower(var.PROJECT)}-tf-locks"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  tags           = local.common_tags

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_ssm_parameter" "locks_table_arn" {
  name  = "tf-locks-table-arn"
  type  = "String"
  value = aws_dynamodb_table.locks_table.arn
}
