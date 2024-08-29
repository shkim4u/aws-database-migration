# Terraform module for creating Amazon DocumentDB cluster.
resource "aws_docdb_subnet_group" "this" {
  name       = "${local.service_name}-docdb-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "Amazon DocumentDB Subnet Group for ${local.service_name}"
  }
}

resource "aws_security_group" "this" {
  name = "${local.service_name}-docdb-sg"
  vpc_id = var.vpc_id
  description = "Allow all inbound for Amazon DocumentDB 27017 port from the VPC"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
}

resource "random_password" "this" {
  length           = 16
  special          = false
#  # Override the special characters to include /, ", and @
#  override_special = "/\"@ "
}

resource "aws_secretsmanager_secret" "this" {
  name = "${local.service_name}-docdbadmin-password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = random_password.this.result
  depends_on = [random_password.this]
}

# In our example cluster we disable TLS to make it simpler to connect to the database.
resource "aws_docdb_cluster_parameter_group" "this" {
  family = "docdb5.0"
  name = "${local.service_name}-docdb-cluster-parameter-group"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${local.service_name}-docdb-cluster"
  master_username         = "docdbadmin"
  master_password         = random_password.this.result
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  apply_immediately = true
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_docdb_subnet_group.this.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count = 2
  # Add count index to the identifier to avoid duplicate resource error.
  identifier = "${local.service_name}-cluster-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.r6g.large"
  apply_immediately = true
  enable_performance_insights = true
}
