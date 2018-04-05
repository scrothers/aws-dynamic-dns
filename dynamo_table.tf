resource "aws_dynamodb_table" "dynamic_dns" {
  name           = "dynamic_dns"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = "${merge(var.common_tags, map("Name", "lambda-dyndns"))}"
}
