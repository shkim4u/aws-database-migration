module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"

  repository_name = "${var.name}"

  #  repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_image_tag_mutability = "MUTABLE"

  tags = {
    Terraform = "true"
    Environment = "Dev"
  }

  repository_force_delete = true
}
