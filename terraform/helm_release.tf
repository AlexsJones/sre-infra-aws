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
  wait             = false
  set {
    name  = "global.hosts.domain"
    value = var.dns_base_domain
  }
  set {
    name  = "global.edition"
    value = "ce"
  }
  set {
    name  = "global.ingress.configureCertmanager"
    value = false
  }
  set {
    name  = "global.ingress.tls.enabled"
    value = false
  }
  set {
    name  = "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"
    value = aws_acm_certificate.eks_domain_cert.id
  }

}
