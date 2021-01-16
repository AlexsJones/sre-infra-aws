data "aws_route53_zone" "base_domain" {
  name = var.dns_base_domain
}

# create AWS-issued SSL certificate
resource "aws_acm_certificate" "eks_domain_cert" {
  domain_name               = var.dns_base_domain
  subject_alternative_names = ["*.${var.dns_base_domain}"]
  validation_method         = "DNS"

  tags = {
    Name            = "${var.dns_base_domain}"
  }
}

resource "aws_route53_record" "deployments_subdomains" {
  for_each = toset(var.deployments_subdomains)
  zone_id = data.aws_route53_zone.base_domain.id
  name    = "${each.key}.${aws_route53_record.eks_domain.fqdn}"
  type    = "CNAME"
  ttl     = "5"
  records = ["${data.kubernetes_service.ingress_gateway.load_balancer_ingress.0.hostname}"]
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

data "kubernetes_service" "ingress_gateway" {
  metadata {
    namespace = "kube-system"
    name = join("-", [helm_release.ingress_gateway.chart, helm_release.ingress_gateway.name])
  }
  depends_on = [helm_release.ingress_gateway]
}

data "aws_elb_hosted_zone_id" "elb_zone_id" {}

resource "aws_route53_record" "eks_domain" {
  zone_id = data.aws_route53_zone.base_domain.id
  name    = var.dns_base_domain
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_gateway.load_balancer_ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.elb_zone_id.id
    evaluate_target_health = true
  }
}
