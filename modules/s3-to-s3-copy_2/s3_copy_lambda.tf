####################################################################################################
# Lambda Function (Loads data from S3 to Redshift)
####################################################################################################

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "python3 -m pip install -r '${path.module}/${local.lambda_root}/requirements.txt' -t '${path.module}/${local.lambda_root}/lib/'"
  }

  triggers = {
    dependencies_versions = filemd5("${path.module}/${local.lambda_root}/requirements.txt")
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

  depends_on = [data.archive_file.s3_to_s3_copy]
}

resource "aws_lambda_function" "s3_to_s3_copy" {
  function_name = local.function_name

  s3_bucket = aws_s3_bucket.aci_resources_bucket.id
  s3_key    = aws_s3_object.s3_to_s3_copy.key

  role             = data.aws_iam_role.fds_resources_access_role.arn
  handler          = "s3_to_s3_copy.lambda_handler"
  source_code_hash = data.archive_file.s3_to_s3_copy.output_base64sha256
  runtime          = local.lambda_runtime

  vpc_config {
    subnet_ids         = var.compute_subnets
    # TODO: ask David
    security_group_ids = ["sg-0ea2537368013586b"]
    # aws_security_groups.this.ids?
    # [aws_default_security_group.redshift_security_group.id]
  }

  environment {
    variables = {
      src_bucket = var.fds_access_point_alias
      dst_bucket = var.data_bucket_name
    }
  }
}
