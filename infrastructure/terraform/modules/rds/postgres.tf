resource "aws_db_subnet_group" "flightspecials" {
  name = "${local.flightspecials_service_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Purpose = "Database subnet group for ${local.flightspecials_service_name}"
  }
}

resource "aws_security_group" "flightspecials_db" {
  name = "${local.flightspecials_service_name}-security-group"
  vpc_id = var.vpc_id
  description = "Allow all inbound for Postgres from the VPC"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
}

resource "aws_db_parameter_group" "flightspecials" {
  name = "${local.flightspecials_service_name}-db-parameter-group"
  family = "postgres14"

  parameter {
    name  = "rds.logical_replication"
    value = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name = "shared_preload_libraries"
    value = "pglogical"
    apply_method = "pending-reboot"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_password" "master" {
  length = 16
  special = true
  override_special = "_!%^@"
}

locals {
  date = formatdate("YYYYMMDD", timestamp())
}

resource "random_id" "secrets_random_id" {
  byte_length = 4
}

# Issue when modifying resources: You can't create this secret because a secret with this name is already scheduled for deletion.
# - How can I immediately delete a Secrets Manager secret so that I can create a new secret with the same name?: https://repost.aws/knowledge-center/delete-secrets-manager-secret
# aws secretsmanager delete-secret --secret-id your-secret-name --force-delete-without-recovery --region your-region
# aws secretsmanager describe-secret --secret-id your-secret-name --region your-region
# An error occurred (ResourceNotFoundException) when calling the DescribeSecret operation: Secrets Manager can't find the specified secret.
# This error means that the secret is successfully deleted.
resource "aws_secretsmanager_secret" "flightspecials_db_credentials_test" {
#  name = "flightspecials_db_credentials_test_${local.date}-${random_id.secrets_random_id.hex}"
  # Restore back to the original simple name with "recovery_window_in_days" = 0, which means force deletion without recovery.
  name = "flightspecials_db_credentials_test"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "flightspecials_db_credentials_test" {
  secret_id = aws_secretsmanager_secret.flightspecials_db_credentials_test.id
  secret_string = random_password.master.result
}

# Database 사용자 및 암호를 Manipulate하고자 한다면 아래 참고
# - https://automateinfra.com/2021/03/24/how-to-create-secrets-in-aws-secrets-manager-using-terraform-in-amazon-account/
# - https://stackoverflow.com/questions/46051538/syntax-for-filters-for-aws-rds-describe-db-instances
# - https://velog.io/@kwakwoohyun/Terraform-AWS-Secrets-Manager
# - https://stackoverflow.com/questions/65603923/terraform-rds-database-credentials
resource "aws_db_instance" "flightspecials" {
  identifier = "${local.flightspecials_service_name}-test-postgres-db"
  db_name = "dso"
  engine = "postgres"
  engine_version = "14.10"
  instance_class = "db.m5.xlarge"
  manage_master_user_password = true
  username = "postgres"
  port = 5432
  allocated_storage = 100
  max_allocated_storage = 200
  db_subnet_group_name = aws_db_subnet_group.flightspecials.name
  deletion_protection = false   # For testing.
  backup_retention_period = 7
  copy_tags_to_snapshot = true
  iam_database_authentication_enabled = true
  vpc_security_group_ids = [aws_security_group.flightspecials_db.id]
  parameter_group_name = aws_db_parameter_group.flightspecials.name
  skip_final_snapshot = true
  timeouts {
    create = "2h"
  }
}
