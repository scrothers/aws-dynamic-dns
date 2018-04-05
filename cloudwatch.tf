resource "aws_cloudwatch_event_rule" "dynamic_dns" {
  name          = "dynamic_dns"
  description   = "Capture instance events and send them to the dynamic DNS Lambda."
  event_pattern = "${file("${path.module}/eventpatterns/dynamic_dns.json")}"
}

resource "aws_cloudwatch_event_target" "dynamic_dns" {
  target_id = "dynamic_dns"
  rule      = "${aws_cloudwatch_event_rule.dynamic_dns.name}"
  arn       = "${aws_lambda_function.dyndns.qualified_arn}"
}

resource "aws_lambda_permission" "dynamic_dns" {
  statement_id  = "dynamic_dns"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.dyndns.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.dynamic_dns.arn}"
  qualifier     = "${aws_lambda_function.dyndns.version}"
}
