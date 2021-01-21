variable "ingress_gateway_chart_name" {
  type    = string
  default = "nginx-ingress"
}

variable "ingress_gateway_chart_repo" {
  type    = string
  default = "https://helm.nginx.com/stable"
}

variable "ingress_gateway_chart_version" {
  type    = string
  default = "0.5.2"
}

variable "ingress_gateway_annotations" {
  type = map(string)
  default = {
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"        = "http",
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"               = "https",
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-connection-idle-timeout" = "60",
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"                    = "elb"
  }
}

resource "helm_release" "ingress_gateway" {
  name             = var.ingress_gateway_chart_name
  namespace        = "gateway"
  chart            = var.ingress_gateway_chart_name
  repository       = var.ingress_gateway_chart_repo
  version          = var.ingress_gateway_chart_version
  create_namespace = true
  dynamic "set" {
    for_each = var.ingress_gateway_annotations

    content {
      name  = set.key
      value = set.value
      type  = "string"
    }
  }

  set {
    name  = "controller.replicaCount"
    value = format("%d", 2 * var.worker_group_size)
  }
  set {
    name  = "controller.service.httpsPort.targetPort"
    value = "http" // This is due to TLS termination at the NLB
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = aws_acm_certificate.eks_domain_cert.id
  }
}

data "kubernetes_service" "ingress_gateway" {
  metadata {
    name      = join("-", [helm_release.ingress_gateway.chart, helm_release.ingress_gateway.name])
    namespace = "gateway"
  }

}

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
