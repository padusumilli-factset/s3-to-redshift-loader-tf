terraform {
  required_version = "> 1.3"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}


module "fds_resources_role" {
  source = "./modules/fds-resources-access-role_1"

  fds_resources_access_role = var.fds_resources_access_role
  aws_region                = var.aws_region
}

module "s3_to_s3_copy" {
  source = "./modules/s3-to-s3-copy_2"

  aws_region = var.aws_region

  vpc_id          = var.vpc_id
  compute_subnets = var.compute_subnets

  fds_resources_access_role_arn = var.fds_resources_access_role_arn
  fds_resources_access_role     = var.fds_resources_access_role
  fds_access_point_arn          = var.fds_access_point_arn
  fds_sns_arn                   = var.fds_sns_arn
  environment                   = var.environment
  timeout                       = var.timeout
  data_bucket_name              = var.data_bucket_name
  resources_bucket_name         = var.resources_bucket_name
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
  rs_nodetype           = var.rs_nodetype
  rs_cluster_type       = var.rs_cluster_type

  vpc_id          = var.vpc_id
  compute_subnets = var.compute_subnets

}