terraform {
  required_version = "> 1.3"
}

locals {
  lambda_root           = "lambda-redshift"
  lambda_redshift_layer = "lambda-redshift-layer"
  lambda_fn_name        = "s3_to_redshift_loader"
  loader_q_name         = "redshift-loader-queue.fifo"
}

resource "aws_sqs_queue" "s3_redshift_loader" {
  name                        = local.loader_q_name
  fifo_queue                  = true
  content_based_deduplication = true

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [{
    "Sid" : "SQSAllowReceive",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "*"
      },
    "Action" : "SQS:*",
    "Resource" : "*"
    }]
}
EOT

  tags = {
    Name = local.loader_q_name
  }
}

data "aws_sns_topic" "s3_to_s3_copy_updates_topic" {
  name = var.s3_to_s3_copy_updates_topic
}

### Event source from SQS
resource "aws_sns_topic_subscription" "loader_sns_topic_subscription" {
  topic_arn            = data.aws_sns_topic.s3_to_s3_copy_updates_topic.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.s3_redshift_loader.arn
  raw_message_delivery = true
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.s3_redshift_loader.arn
  enabled          = true
  function_name    = aws_lambda_function.s3_to_redshift_loader_fn.arn
  batch_size       = 1
  depends_on       = [
    aws_lambda_function.s3_to_redshift_loader_fn
  ]
}
