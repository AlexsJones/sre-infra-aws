output "aws_acm_certificate" {
  description = "ACM cert ID"
  value       = module.cluster.aws_acm_certificate
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.cluster.cluster_endpoint
}

output "cluster_cert" {
  description = "Cluster cert"
  value       = module.cluster.cluster_cert
}

output "cluster_token" {
  description = "Cluster token"
  value       = module.cluster.cluster_token
}
