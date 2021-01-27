data "kubernetes_service" "gitlab_ingress" {
  metadata {
    namespace = "gitlab"
    name      = "gitlab-nginx-ingress-controller"
  }
}
