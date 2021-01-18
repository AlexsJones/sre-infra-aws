resource "helm_release" "spot_termination_handler" {
  name      = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  repository      = "https://aws.github.io/eks-charts"
  version   = "0.9.1"
  namespace = "kube-system"
}
############################################################
resource "helm_release" "gitlab" {
  name = "gitlab"
  chart = "gitlab"
  repository = "https://charts.gitlab.io/"
  namespace = "gitlab"
  version = "4.7.4"
  create_namespace = true

  set {
    name = "nginx-ingress.enabled"
    value = true
  }
  set {
    name = "global.hosts.domain"
    value = var.dns_base_domain
  }
  set {
    name = "global.edition"
    value = "ce"
  }
  set {
    name = "certmanager-issuer.email"
    value = var.certmanager_email
  }
}

data "kubernetes_ingress" "gitlab-web" {
  metadata {
    name = "gitlab-webservice-default"
    namespace = "gitlab"
  }
  depends_on=[helm_release.gitlab]
}

resource "aws_route53_record" "gitlab_subdomain" {
  zone_id = data.aws_route53_zone.base_domain.id
  name    = join(".",["gitlab",var.dns_base_domain])
  type    = "CNAME"

  alias {
    name =  data.kubernetes_ingress.gitlab-web.load_balancer_ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.elb_zone_id.id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "gitlab_minio_subdomain" {
  zone_id = data.aws_route53_zone.base_domain.id
  name    = join(".",["minio",var.dns_base_domain])
  type    = "CNAME"

  alias {
    name =  data.kubernetes_ingress.gitlab-web.load_balancer_ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.elb_zone_id.id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "gitlab_registry_subdomain" {
  zone_id = data.aws_route53_zone.base_domain.id
  name    = join(".",["registry",var.dns_base_domain])
  type    = "CNAME"

  alias {
    name =  data.kubernetes_ingress.gitlab-web.load_balancer_ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.elb_zone_id.id
    evaluate_target_health = true
  }
}
############################################################
