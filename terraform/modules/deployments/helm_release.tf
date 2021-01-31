variable "aws_acm_certificate" {}
variable "dns_base_domain" {}

variable "ingress_gateway_annotations" {
  type = map(string)
  default = {
    "controller.service.httpPort.targetPort"                                                                    = "http",
    "controller.service.httpsPort.targetPort"                                                                   = "http",
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"        = "http",
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"               = "https",
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-connection-idle-timeout" = "60",
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"                    = "elb"
  }
}

variable "certmanager_email" {
  type    = string
  default = "alexsimonjones@gmail.com"
}

resource "helm_release" "spot_termination_handler" {
  name       = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts"
  version    = "0.9.1"
  namespace  = "kube-system"
}

resource "helm_release" "gitlab" {
  name             = "gitlab"
  chart            = "gitlab"
  repository       = "https://charts.gitlab.io/"
  namespace        = "gitlab"
  version          = "4.7.4"
  create_namespace = true

  set {
    name  = "global.hosts.domain"
    value = var.dns_base_domain
  }
  set {
    name  = "global.edition"
    value = "ce"
  }
  set {
    name  = "certmanager-issuer.email"
    value = var.certmanager_email
  }
  set {
    name  = "global.ingress.tls.enabled"
    value = "false"
  }
  set {
    name  = "nginx.controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = var.aws_acm_certificate
  }
}

resource "helm_release" "ingress_gateway" {
  name       = "nginx-ingress"
  chart      = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  version    = "0.5.2"
  namespace  = "kube-system"
  wait       = true
  dynamic "set" {
    for_each = var.ingress_gateway_annotations
    content {
      name  = set.key
      value = set.value
      type  = "string"
    }
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = var.aws_acm_certificate
  }
}
