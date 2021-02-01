output "aws_acm_certificate" {
  description = "ACM cert ID"
  value       = module.cluster.aws_acm_certificate
}
