variable "kube_version" {
  type    = string
  default = "1.18"
}

variable "worker_group_size" {
  type    = number
  default = 3
}

variable "instance_type" {
  type    = string
  default = "m4.large"
}

variable "cluster_name" {
  type    = string
  default = "sre-infra"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "dns_base_domain" {
  type    = string
  default = "dp-arena.com"
}
