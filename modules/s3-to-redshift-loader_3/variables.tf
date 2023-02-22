variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile credentials to be used for setting up the infrastructure"
  default     = "default"
}

variable "data_bucket_name" {
  description = "Bucket in which the data will be stored."
}

variable "resources_bucket_name" {
  description = "Bucket in which the .zip and .jar files of source code will be placed"
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

variable "vpc_id" {}

variable "compute_subnets" {
  description = "list of subnets"
  default     = ["subnet-00e0f9865d0317d4f", "subnet-0db9b3496cdf10db9"]
}

variable "redshift_subnet_group_name" {}

variable "environment" {}