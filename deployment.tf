variable "common_tags" {
  type        = "map"
  description = "A list of common tags for all resources to be created with."
  default     = {}
}

variable "domain" {
  type        = "string"
  description = "The domain being used for cluster DNS resources."
}

variable "zone_id" {
  type        = "string"
  description = "The zone identifier for dynamic updates."
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda.py"
  output_path = "${path.module}/lambda/lambda.zip"
}

resource "aws_lambda_function" "dyndns" {
  filename         = "${path.module}/lambda/lambda.zip"
  function_name    = "dyndns"
  role             = "${aws_iam_role.lambda_dyndns.arn}"
  handler          = "lambda.lambda_handler"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  runtime          = "python3.6"
  description      = "Dynamic DNS service for node auto discovery."
  memory_size      = 1024
  timeout          = 5
  publish          = true
  tags             = "${merge(var.common_tags, map("Name", "lambda-dyndns"))}"

  environment {
    variables = {
      ZONE_ID  = "${var.zone_id}"
      DNS_ZONE = "${var.domain}"
    }
  }
}
