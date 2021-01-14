resource "helm_release" "spot_termination_handler" {
  name      = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  repository      = "https://aws.github.io/eks-charts"
  version   = "0.9.1"
  namespace = "kube-system"
}
resource "helm_release" "ingress_gateway" {
  name      = "nginx-ingress"
  chart      = "nginx-ingress"
  repository      = "https://helm.nginx.com/stable"
  version   = "0.5.2"
  namespace = "kube-system"
  wait = false
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
    value = aws_acm_certificate.eks_domain_cert.id
  }
}
