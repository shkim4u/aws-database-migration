# Being different from PostgreSQL database, now let's create Amazon RDS Aurora MySQL using Terraform module.
# Refer to: https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/latest
resource "aws_db_subnet_group" "m2m_general" {
  name = "${local.general_service_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Purpose = "Database subnet group for ${local.general_service_name}"
  }
}

module "aurora" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name            = "${local.general_service_name}-aurora-mysql"
  engine          = "aurora-mysql"
  engine_version  = "8.0"
  master_username = "root"
  database_name = "m2m"
  instances = {
    1 = {
      instance_class      = "db.r5.large"
#      publicly_accessible = false
    }
    2 = {
      identifier     = "mysql-static-1"
      instance_class = "db.r5.2xlarge"
    }
    3 = {
      identifier     = "mysql-excluded-1"
      instance_class = "db.r5.xlarge"
      promotion_tier = 15
    }
  }

  autoscaling_enabled      = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 5

  vpc_id               = var.vpc_id
  db_subnet_group_name = aws_db_subnet_group.m2m_general.name
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = [var.vpc_cidr_block]
    }
#    kms_vpc_endpoint = {
#      type                     = "egress"
#      from_port                = 443
#      to_port                  = 443
#      source_security_group_id = module.vpc_endpoints.security_group_id
#    }
  }

  apply_immediately   = true
  skip_final_snapshot = true

  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = "${local.general_service_name}-db-cluster-parameter-group"
  db_cluster_parameter_group_family      = "aurora-mysql8.0"
  db_cluster_parameter_group_description = "${local.general_service_name} cluster parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 120
      apply_method = "immediate"
    }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
    }, {
      name         = "log_output"
      value        = "FILE"
      apply_method = "immediate"
    }, {
      name         = "max_allowed_packet"
      value        = "67108864"
      apply_method = "immediate"
    }, {
      name         = "aurora_parallel_query"
      value        = "OFF"
      apply_method = "pending-reboot"
    }, {
      name         = "binlog_format"
      value        = "ROW"
      apply_method = "pending-reboot"
    }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
    }, {
      name         = "require_secure_transport"
      value        = "OFF"
      apply_method = "immediate"
    }, {
      name         = "tls_version"
      value        = "TLSv1.2"
      apply_method = "pending-reboot"
    }
  ]

  create_db_parameter_group      = true
  db_parameter_group_name        = "${local.general_service_name}-db-parameter-group"
  db_parameter_group_family      = "aurora-mysql8.0"
  db_parameter_group_description = "${local.general_service_name} DB parameter group"
  db_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 60
      apply_method = "immediate"
    }, {
      name         = "general_log"
      value        = 0
      apply_method = "immediate"
    }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
    }, {
      name         = "log_output"
      value        = "FILE"
      apply_method = "pending-reboot"
    }, {
      name         = "long_query_time"
      value        = 5
      apply_method = "immediate"
    }, {
      name         = "max_connections"
      value        = 2000
      apply_method = "immediate"
    }, {
      name         = "slow_query_log"
      value        = 1
      apply_method = "immediate"
    }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
    }
  ]

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

#  create_db_cluster_activity_stream     = true
#  db_cluster_activity_stream_kms_key_id = module.kms.key_id

  manage_master_user_password = true

#  manage_master_user_password_rotation              = true
#  master_user_password_rotation_schedule_expression = "rate(15 days)"

  # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/DBActivityStreams.Overview.html#DBActivityStreams.Overview.sync-mode
#  db_cluster_activity_stream_mode = "async"

#  tags = local.tags
}

#resource "aws_db_subnet_group" "m2m_general" {
#  name = "${local.general_service_name}-db-subnet-group"
#  subnet_ids = var.subnet_ids
#
#  tags = {
#    Purpose = "Database subnet group for ${local.general_service_name}"
#  }
#}
