variable "cluster_name" {
  type = string
  default = "sre-infra"
}
variable "kube_version" {
  type = string
  default = "1.18"
}
variable "worker_group_size" {
  type = number
  default = 3
}
variable "region" {
  type = string
  default = "us-east-2"
}
variable "dns_base_domain" {
  type = string
}
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
