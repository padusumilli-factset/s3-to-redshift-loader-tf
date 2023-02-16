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

# provider "aws" {
#   profile = var.aws_profile
#   //use fds region for SNS, usually us-east-1
#   region  = var.fds_aws_region
#   alias   = "sns2sqs"
#   assume_role {
#     role_arn = var.fds_resources_access_role_arn
#     # for cross region use sqs account and sns region
#   }
# }

locals {
  lambda_root    = "lambda-s3-copy"
  function_name  = "s3_to_s3_copy"
  lambda_runtime = "python3.9"
}

## S3 buckets
resource "aws_s3_bucket" "aci_data_bucket" {
  bucket = var.data_bucket_name

  tags = {
    Name        = "Data bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "aci_resources_bucket" {
  bucket = var.resources_bucket_name

  tags = {
    Name        = "Lambda and other resources bucket"
    Environment = var.environment
  }
}

## SQS
resource "aws_sqs_queue" "s3_to_s3_copy" {
  name                        = "s3-copy-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  # TODO Add DLQ
  #   redrive_policy = jsonencode({
  #     deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
  #     maxReceiveCount     = 4
  #   })
  #   redrive_allow_policy = jsonencode({
  #     redrivePermission = "byQueue",
  #     sourceQueueArns   = [aws_sqs_queue.terraform_queue_deadletter.arn]
  #   })

  tags = {
    Name = "s3-to-s3-coppy-queue"
  }
}

resource "aws_sns_topic_subscription" "loader_sns_topic_subscription" {
  provider  = aws.sns2sqs
  topic_arn = var.fds_sns_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.s3_to_s3_copy.arn
}


# Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.s3_to_s3_copy.arn
  enabled          = true
  function_name    = aws_lambda_function.s3_to_s3_copy.arn
  batch_size       = 1
  depends_on       = [
    aws_lambda_function.s3_to_s3_copy
  ]
}