data "aws_iam_role" "fds_resources_access_role" {
  name = var.fds_resources_access_role
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_security_groups" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}