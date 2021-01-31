variable "dns_base_domain_id" {}
variable "elb_zone_id" {}


# Default Ingress controller
resource "aws_route53_record" "eks_domain" {
  zone_id = var.dns_base_domain_id
  name    = var.dns_base_domain
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_gateway.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = var.elb_zone_id
    evaluate_target_health = true
  }
}

# Gitlab Ingress Controller
resource "aws_route53_record" "gitlab_subdomain" {
  zone_id = var.dns_base_domain_id
  name    = join(".", ["gitlab", var.dns_base_domain])
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_gateway.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = var.elb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "gitlab_minio_subdomain" {
  zone_id = var.dns_base_domain_id
  name    = join(".", ["minio", var.dns_base_domain])
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_gateway.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = var.elb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "gitlab_registry_subdomain" {
  zone_id = var.dns_base_domain_id
  name    = join(".", ["registry", var.dns_base_domain])
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_gateway.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = var.elb_zone_id
    evaluate_target_health = true
  }
}
