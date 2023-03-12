terraform {
  required_version = "> 1.3"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.0"
      configuration_aliases = [aws.sns2sqs]
    }
  }
}

locals {
  lambda_root           = "lambda-s3-copy"
  s3_copy_fn_name       = "s3_to_s3_copy"
  lambda_runtime        = "python3.9"
  copy_job_queue        = "s3-copy-queue.fifo"
  data_bucket_name      = var.data_bucket_name
  resources_bucket_name = var.resources_bucket_name
}
## SNS local S3 copy topic
resource "aws_sns_topic" "s3_to_s3_copy_updates" {
  name                        = "s3-to-s3-copy-updates-topic.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
}

## S3 buckets
resource "aws_s3_bucket" "aci_data_bucket" {
  bucket = var.data_bucket_name

  tags = {
    Name        = local.data_bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "aci_resources_bucket" {
  bucket = var.resources_bucket_name

  tags = {
    Name        = local.resources_bucket_name
    Environment = var.environment
  }
}

## SQS
resource "aws_sqs_queue" "s3_to_s3_copy" {
  name                        = local.copy_job_queue
  fifo_queue                  = true
  content_based_deduplication = true
  policy                      = <<EOT
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
    Name = local.copy_job_queue
  }
}

# Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  provider         = aws
  event_source_arn = aws_sqs_queue.s3_to_s3_copy.arn
  enabled          = true
  function_name    = aws_lambda_function.s3_to_s3_copy.arn
  batch_size       = 1
  depends_on       = [
    aws_lambda_function.s3_to_s3_copy
  ]
}

resource "aws_sns_topic_subscription" "loader_sns_topic_subscription" {
  provider             = aws.sns2sqs
  topic_arn            = var.fds_sns_arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.s3_to_s3_copy.arn
  raw_message_delivery = true
}
