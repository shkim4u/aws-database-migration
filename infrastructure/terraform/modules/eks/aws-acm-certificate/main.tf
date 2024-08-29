/**
 * Certificate using private CA for various ALBs.
 */
resource "aws_acm_certificate" "this" {
  # If "eks_cluster_name" contains "Production", then use production CA.
  # Otherwise, use staging CA.
  domain_name = strcontains(var.eks_cluster_name, "Production") ? var.domain_name : var.domain_name_staging
#  subject_alternative_names = var.subject_alternative_names
  certificate_authority_arn = var.certificate_authority_arn

  tags = {
    Environment = var.eks_cluster_name
  }
}
