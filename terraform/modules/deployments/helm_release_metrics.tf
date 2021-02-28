resource "helm_release" "metrics" {
  name             = "metrics-server"
  chart            = "metrics-server"
  repository       = "https://kubernetes-charts.banzaicloud.com"
  namespace        = "kube-system"
  version          = "0.0.8"
  create_namespace = false
  wait             = false
}
