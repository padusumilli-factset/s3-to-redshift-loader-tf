terraform {
  required_version = "> 1.3"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

locals {
  lambda_root = "lambda-redshift"
}

resource "aws_sqs_queue" "s3_redshift_loader_q" {
  name                        = "redshift-loder-queue.fifo"
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
    Name = "redshift-loader-job-queue"
  }
}
## Event source from SQS
# resource "aws_lambda_event_source_mapping" "event_source_mapping" {
#   event_source_arn = aws_sqs_queue.s3_loader_notification_sqs.arn
#   enabled          = true
#   function_name    = aws_lambda_function.s3_to_redshift_loader.arn
#   batch_size       = 1
#   depends_on = [
#     aws_lambda_function.s3_to_redshift_loader
#   ]
# }