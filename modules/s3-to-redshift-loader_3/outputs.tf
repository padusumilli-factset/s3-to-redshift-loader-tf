output "redshift_loader_q_url" {
  value = aws_sqs_queue.s3_redshift_loader.url
}
