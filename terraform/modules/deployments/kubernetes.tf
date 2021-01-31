data "kubernetes_service" "ingress_gateway" {
  metadata {
    namespace = "kube-system"
    name      = join("-", [helm_release.ingress_gateway.chart, helm_release.ingress_gateway.name])
  }
}

data "kubernetes_service" "gitlab_ingress" {
  metadata {
    namespace = "gitlab"
    name      = "gitlab-nginx-ingress-controller"
  }
}
