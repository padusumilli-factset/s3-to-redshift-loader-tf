terraform {
  required_version = "> 1.3"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

provider "aws" {
  profile = var.aws_profile
  //use fds region for SNS, usually us-east-1
  region  = var.fds_aws_region
  alias   = "sns2sqs"
  assume_role {
    role_arn = data.aws_iam_role.fds_resources_access_role.arn
    # for cross region use sqs account and sns region
  }
}


module "fds_resources_role" {
  source = "./modules/fds-resources-access-role_1"

  count = data.aws_iam_role.fds_resources_access_role.arn == true ? 1 : 0

  fds_resources_access_role = var.fds_resources_access_role
  aws_region                = var.aws_region
}

module "s3_to_s3_copy" {
  source    = "./modules/s3-to-s3-copy_2"
  providers = {
    aws.sns2sqs = aws.sns2sqs
  }

  aws_region = var.aws_region

  vpc_id                     = var.vpc_id
  compute_subnets            = var.compute_subnets
  redshift_subnet_group_name = var.redshift_subnet_group_name
  fds_resources_access_role  = var.fds_resources_access_role
  fds_access_point_alias       = var.fds_access_point_alias
  fds_sns_arn                = var.fds_sns_arn
  environment                = var.environment
  timeout                    = var.timeout
  data_bucket_name           = var.data_bucket_name
  resources_bucket_name      = var.resources_bucket_name
}


module "redshift_loader" {
  source = "./modules/s3-to-redshift-loader_3"

  aws_region            = var.aws_region
  data_bucket_name      = var.data_bucket_name
  resources_bucket_name = var.resources_bucket_name
  rs_cluster_identifier = var.rs_cluster_identifier
  rs_database_name      = var.rs_database_name
  rs_master_username    = var.rs_master_username
  rs_master_pass        = var.rs_master_pass
  rs_node_type          = var.rs_node_type
  rs_cluster_type       = var.rs_cluster_type

  vpc_id                     = var.vpc_id
  compute_subnets            = var.compute_subnets
  redshift_subnet_group_name = var.redshift_subnet_group_name
  environment                = var.environment

  depends_on = [module.s3_to_s3_copy]
}