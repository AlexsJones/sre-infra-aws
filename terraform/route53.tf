variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "dns_base_domain" {
  type    = string
  default = "cloud-skunkworks.co.uk"
}

data "aws_route53_zone" "base_domain" {
  name = var.dns_base_domain
}

data "aws_elb_hosted_zone_id" "elb_zone_id" {}

resource "aws_acm_certificate" "eks_domain_cert" {
  domain_name               = var.dns_base_domain
  subject_alternative_names = [join(".", ["*", var.dns_base_domain])]
  validation_method         = "DNS"

  tags = {
    Name = var.dns_base_domain
  }
}
resource "aws_route53_record" "eks_domain_cert_validation_dns" {
  for_each = {
    for dvo in aws_acm_certificate.eks_domain_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.base_domain.zone_id
}

resource "aws_acm_certificate_validation" "eks_domain_cert_validation" {
  certificate_arn         = aws_acm_certificate.eks_domain_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.eks_domain_cert_validation_dns : record.fqdn]
}
# Default Ingress controller
resource "aws_route53_record" "eks_domain" {
  zone_id = data.aws_route53_zone.base_domain.id
  name    = var.dns_base_domain
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_gateway.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.elb_zone_id.id
    evaluate_target_health = true
  }
}

# Gitlab Ingress Controller
resource "aws_route53_record" "gitlab_subdomain" {
  zone_id = data.aws_route53_zone.base_domain.id
  name    = join(".", ["gitlab", var.dns_base_domain])
  type    = "A"

  alias {
    name                   = data.kubernetes_service.gitlab_ingress.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.elb_zone_id.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "gitlab_minio_subdomain" {
  zone_id = data.aws_route53_zone.base_domain.id
  name    = join(".", ["minio", var.dns_base_domain])
  type    = "A"

  alias {
    name                   = data.kubernetes_service.gitlab_ingress.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.elb_zone_id.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "gitlab_registry_subdomain" {
  zone_id = data.aws_route53_zone.base_domain.id
  name    = join(".", ["registry", var.dns_base_domain])
  type    = "A"

  alias {
    name                   = data.kubernetes_service.gitlab_ingress.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.elb_zone_id.id
    evaluate_target_health = true
  }
}
