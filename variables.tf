variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "fds_aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile credentials to be used for setting up the infrastructure"
  default     = "default"
}

variable "fds_resources_access_role" {

}

variable "s3_to_s3_copy_updates_topic" {
  description = "FactSet S3 to local S3 bucket copy updates for downstream piepline processing, like loading in to RedShift"
}

variable "fds_access_point_alias" {
  description = "FactSet S3 Access Point ARN to be provided by FactSet on account setup"
}

variable "fds_sns_arn" {
  description = "FactSet Simple Notification Service (SNS) ARN to be subscribed by SQS for file notifications"
}

variable "environment" {
  description = "AWS Environment tag"
  default     = "Proof of Concept"
}

variable "app_name" {
  description = "Name of the application, will be prefixed to all resource names -- redshiftloader-poc"
  default     = "s3_to_redshift_loader"
}

### Network

variable "vpc_id" {}

variable "compute_subnets" {
  description = "list of subnets"
  default     = ["subnet-00e0f9865d0317d4f", "subnet-0db9b3496cdf10db9"]
}

variable "redshift_subnet_group_name" {
  default = "redshift-subnet-analytics"
}

### S3
variable "data_bucket_name" {
  description = "Bucket in which the data will be stored."
}

variable "resources_bucket_name" {
  description = "Bucket in which the .zip and .jar files of source code will be placed"
}

variable "resources_s3_prefix" {
  description = "S3 path where the .jar files and the python script will be placed"
  default     = "fds/redshift_loader"
}

variable "availability_zone_1" {
  description = "aws subnet availability zone 1"
  default     = "us-east-2a"
}

variable "availability_zone_2" {
  description = "aws subnet availability zone 2"
  default     = "us-east-2b"
}


### RedShift cluster
variable "rs_cluster_identifier" {
  description = "Name of the Redshift cluster"
  default     = "poc-cluster"
}

variable "rs_database_name" {
  description = "Database name to load the data"
  default     = "fds-data"
}


variable "rs_master_username" {}

variable "rs_master_pass" {}

variable "rs_node_type" {}

variable "rs_cluster_type" {
  description = "number of nodes"
}

## Lambda configuration

variable "retries" {
  description = "Default number of retries for failed jobs"
  default     = 0
}

variable "timeout" {
  description = "Default job timeout (minutes)"
  default     = 300
}

