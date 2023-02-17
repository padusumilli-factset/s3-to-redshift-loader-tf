variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile credentials to be used for setting up the infrastructure"
  default     = "default"
}

variable "fds_resources_access_role" {
  description = "A role to be permission for FactSet resources"
  default     = "fds_resources_access_role"
}

