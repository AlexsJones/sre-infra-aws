output "ingress_hostname" {
  description = "Ingress hostname"
  value       = data.kubernetes_service.ingress_gateway.status.0.load_balancer.0.ingress.0.hostname
}
