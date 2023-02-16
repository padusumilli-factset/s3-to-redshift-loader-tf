data "aws_vpc" "selected" {
  id = var.vpc_id
}

# resource "aws_subnet" "redshift_subnet_1" {
#   vpc_id                  = data.aws_vpc.selected.id
#   cidr_block              = cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 1)
#   availability_zone       = var.aws_availability_zone_1
#   map_public_ip_on_launch = "true"

#   tags = {
#     Name = "redshift-subnet-1"
#   }
# }

# resource "aws_subnet" "redshift_subnet_2" {
#   vpc_id                  = data.aws_vpc.selected.id
#   cidr_block              = cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 1)
#   availability_zone       = var.aws_availability_zone_2
#   map_public_ip_on_launch = "true"

#   tags = {
#     Name = "redshift-subnet-2"
#   }
# }

resource "aws_redshift_subnet_group" "analytics" {
  name       = var.redshift_subnet_group_name
  subnet_ids = var.compute_subnets

  tags = {
    environment = var.environment
    Name        = var.redshift_subnet_group_name
  }
}

resource "aws_default_security_group" "analytics" {
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redshift-sg"
  }
}



resource "aws_redshift_cluster" "analytics" {
  cluster_identifier  = var.rs_cluster_identifier
  database_name       = var.rs_database_name
  master_username     = var.rs_master_username
  master_password     = var.rs_master_pass
  node_type           = var.rs_node_type
  cluster_type        = var.rs_cluster_type
  skip_final_snapshot = true
  iam_roles           = ["${aws_iam_role.redshift_lambda_execution.arn}"]


  cluster_subnet_group_name = aws_redshift_subnet_group.analytics.id

  depends_on = [
    aws_iam_role.redshift_lambda_execution,
    aws_default_security_group.analytics,
    aws_redshift_subnet_group.analytics,
  ]
}

## create schema once the redshift cluster is created