variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile credentials to be used for setting up the infrastructure"
  default     = "default"
}

variable "fds_resources_access_role_arn" {
  description = "FactSet resources including SNS and S3 access point resources access role arn, this will be generated in the first step"
}

variable "fds_resources_access_role" {

}
variable "fds_access_point_arn" {
  description = "FactSet S3 Access Point ARN to be provided by FactSet on account setup"
}

variable "fds_sns_arn" {
  description = "FactSet Simple Notification Service (SNS) ARN to be subscribed by SQS for file notifications"
}

variable "vpc_id" {}

variable "compute_subnets" {
  default     = ["subnet-00e0f9865d0317d4f", "subnet-0db9b3496cdf10db9"]
  description = "A list of subnets to attach lambda and other resources"
}

variable "environment" {
  description = "AWS Environment tag"
  default     = "Proof of Concept"
}

variable "retries" {
  description = "Default number of retries for failed jobs"
  default     = 0
}

variable "timeout" {
  description = "Default job timeout (minutes)"
  default     = 300
}

### S3
variable "data_bucket_name" {
  description = "Bucket in which the data will be stored."
}

variable "resources_bucket_name" {
  description = "Bucket in which the .zip and .jar files of source code will be placed"
}


