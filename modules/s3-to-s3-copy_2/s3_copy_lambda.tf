####################################################################################################
# Lambda Function (Loads data from source S3 Access Point to target S3)
####################################################################################################

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "python3 -m pip install -r '${path.module}/requirements.txt' -t '${path.module}/${local.lambda_root}/lib/'"
  }

  triggers = {
    dependencies_versions = filemd5("${path.module}/requirements.txt")
    source_versions       = filemd5("${path.module}/${local.lambda_root}/s3_to_s3_copy.py")
    # helper_versions = filemd5("${var.lambda_root}/helpers.py")
  }
}

data "archive_file" "s3_to_s3_copy" {
  type = "zip"

  source_dir  = "${path.module}/${local.lambda_root}"
  output_path = "${path.module}/${local.lambda_root}.zip"

  depends_on = [null_resource.install_dependencies]
}

resource "aws_s3_object" "s3_to_s3_copy" {
  bucket = aws_s3_bucket.aci_resources_bucket.id

  key    = "${local.lambda_root}.zip"
  source = data.archive_file.s3_to_s3_copy.output_path

  etag = filemd5(data.archive_file.s3_to_s3_copy.output_path)

  depends_on = [null_resource.install_dependencies, data.archive_file.s3_to_s3_copy]
}

resource "aws_default_security_group" "lambda" {
  vpc_id = data.aws_vpc.selected.id

  ingress {
    description = "Limit traffic to Redshift port"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Any traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-sg"
  }
}

resource "aws_lambda_function" "s3_to_s3_copy" {
  function_name = local.s3_copy_fn_name

  s3_bucket = aws_s3_bucket.aci_resources_bucket.id
  s3_key    = aws_s3_object.s3_to_s3_copy.key

  role             = data.aws_iam_role.fds_resources_access_role.arn
  handler          = "s3_to_s3_copy.lambda_handler"
  source_code_hash = data.archive_file.s3_to_s3_copy.output_base64sha256
  runtime          = local.lambda_runtime
  timeout          = 30

  environment {
    variables = {
      src_bucket = var.fds_access_point_alias
      dst_bucket = var.data_bucket_name
      topic_arn      = aws_sns_topic.s3_to_s3_copy_updates.arn
    }
  }
}
