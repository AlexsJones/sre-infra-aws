variable "cluster_endpoint" {}
variable "cluster_cert" {}
variable "cluster_token" {}
variable "region" {}
variable "kubeconfig_filename" {}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  config_path = var.kubeconfig_filename
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_filename

  }
}
