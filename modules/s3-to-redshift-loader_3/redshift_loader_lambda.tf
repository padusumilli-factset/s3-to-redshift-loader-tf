####################################################################################################
# Lambda Function (Loads data from S3 to Redshift)
####################################################################################################

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "python3 -m pip install -r '${path.module}/${local.lambda_root}/requirements.txt' -t '${path.module}/${local.lambda_root}/lib/'"
    #    --platform manylinux1_x86_64 --only-binary=:all:
  }

  triggers = {
    dependencies_versions = filemd5("${path.module}/${local.lambda_root}/requirements.txt")
    source_versions       = filemd5("${path.module}/${local.lambda_root}/redshift_loader.py")
    # helper_versions = filemd5("${local.lambda_root}/helpers.py")
  }
}


data "archive_file" "s3_to_redshift_loader" {
  type = "zip"

  source_dir  = "${path.module}/${local.lambda_root}"
  output_path = "${path.module}/${local.lambda_root}.zip"

  depends_on = [null_resource.install_dependencies]
}


resource "aws_s3_object" "s3_to_redshift_loader" {
  bucket = var.resources_bucket_name

  key    = "${local.lambda_root}.zip"
  source = data.archive_file.s3_to_redshift_loader.output_path

#  etag = filemd5(data.archive_file.s3_to_redshift_loader.output_path)

  depends_on = [data.archive_file.s3_to_redshift_loader]
}


resource "aws_lambda_function" "s3_to_redshift_loader_fn" {
  function_name = local.lambda_fn_name

  s3_bucket = var.resources_bucket_name
  s3_key    = aws_s3_object.s3_to_redshift_loader.key
  #  role      = "arn:aws:iam::648803228730:role/service-execution-iam-role"

  role             = aws_iam_role.redshift_lambda_execution.arn
  handler          = "redshift_loader.lambda_handler"
  source_code_hash = data.archive_file.s3_to_redshift_loader.output_base64sha256
  runtime          = "python3.9"

  vpc_config {
    subnet_ids         = var.compute_subnets
    security_group_ids = [aws_default_security_group.analytics.id]
  }

  environment {
    variables = {
      src_bucket    = var.data_bucket_name
      database_name = var.rs_database_name
      user          = var.rs_master_username
      password      = var.rs_master_pass
      schema        = var.rs_database_name
      aws_region    = var.aws_region
      host          = aws_redshift_cluster.analytics.dns_name
    }
  }

  depends_on = [
    aws_default_security_group.analytics
  ]
}
