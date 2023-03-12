resource "aws_redshift_subnet_group" "analytics" {
  name       = var.redshift_subnet_group_name
  subnet_ids = var.compute_subnets

  tags = {
    environment = var.environment
    Name        = var.redshift_subnet_group_name
  }
}

resource "aws_default_security_group" "redshift" {
  vpc_id = data.aws_vpc.selected.id

  ingress {
    description = "Limit traffic to Redshift port"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Any traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
  iam_roles           = [aws_iam_role.redshift_lambda_execution.arn]
  cluster_subnet_group_name = aws_redshift_subnet_group.analytics.id

  publicly_accessible = false
  enhanced_vpc_routing = true

  depends_on = [
    aws_iam_role.redshift_lambda_execution,
    aws_default_security_group.redshift,
    aws_redshift_subnet_group.analytics,
  ]
}