terraform {
  required_version = "> 1.3"
}

locals {
  lambda_root    = "lambda-redshift"
  lambda_fn_name = "s3_to_redshift_loader_1"
  loader_q_name = "redshift-loader-queue.fifo"
}

resource "aws_sqs_queue" "s3_redshift_loader_q" {
  name                        = local.loader_q_name
  fifo_queue                  = true
  content_based_deduplication = true

  tags = {
    Name = local.loader_q_name
  }
}

## Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.s3_redshift_loader_q.arn
  enabled          = true
  function_name    = aws_lambda_function.s3_to_redshift_loader_fn.arn
  batch_size       = 1
  depends_on       = [
    aws_lambda_function.s3_to_redshift_loader_fn
  ]
}