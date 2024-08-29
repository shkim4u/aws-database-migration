###
### Referenes
### - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster
###
resource "aws_cloudwatch_log_group" "m2m_msk" {
  name = "/m2m/msk/M2M-MSK-Cluster"
  retention_in_days = 7

  tags = {
    Environment = "Test/Dev/Prod"
    Application = "M2M"
  }
}

resource "aws_security_group" "m2m_msk" {
  name = "M2M-MSK-Cluster-Security-Group"
  vpc_id = var.vpc_id
  description = "Security group for M2M MSK cluster"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port = 9092
    to_port = 9092
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Kafka communication (Plaintext)"
  }
  ingress {
    from_port = 9094
    to_port = 9094
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Kafka communication (TLS)"
  }
  ingress {
    from_port = 9096
    to_port = 9096
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Kafka communication (SASL/SCRAM)"
  }
  ingress {
    from_port = 9098
    to_port = 9098
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Kafka communication (IAM)"
  }
  ingress {
    from_port = 2181
    to_port = 2181
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Kafka ZooKeeper"
  }
}


resource "aws_msk_cluster" "m2m_msk" {
  cluster_name = "M2M-MSK-Cluster"
  kafka_version = "2.8.1"
  number_of_broker_nodes = (length(var.subnet_ids) * 2)
  broker_node_group_info {
    client_subnets = var.subnet_ids
    instance_type = "kafka.m5.large"
    security_groups = [aws_security_group.m2m_msk.id]
  }
  encryption_info {
    encryption_in_transit {
      in_cluster = true
      client_broker = "TLS"
    }
  }
  client_authentication {
    sasl {
      iam = true
    }
  }
  enhanced_monitoring = "PER_TOPIC_PER_BROKER"
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled = true
        log_group = aws_cloudwatch_log_group.m2m_msk.name
      }
    }
  }
  tags = {
    Description = "MSK Cluster for M2M project"
    Owner = "AWS ProServe"
  }

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

# [2024-03-16] IAM policy to be attached to the IAM role that is used by the pods in EKS cluster.
# Pod identities or IRSA.
data "aws_iam_policy_document" "msk_cluster_access_policy_document" {
    statement {
      effect = "Allow"
      actions = [
        "kafka:*",
        "kafka-cluster:Connect",
        "kafka-cluster:*Topic*",
        "kafka-cluster:ReadData",
        "kafka-cluster:WriteData",
        "kafka-cluster:DescribeGroup",
        "kafka-cluster:AlterGroup"
      ]
      resources = [
        aws_msk_cluster.m2m_msk.arn,
        "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.m2m_msk.cluster_name}/*",
        "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${aws_msk_cluster.m2m_msk.cluster_name}/*"
      ]
    }
}

resource "aws_iam_policy" "msk_cluster_access_policy" {
  name = "${aws_msk_cluster.m2m_msk.cluster_name}-Access-Policy"
  description = "Access policy for ${aws_msk_cluster.m2m_msk.cluster_name}"
  policy = data.aws_iam_policy_document.msk_cluster_access_policy_document.json
}
