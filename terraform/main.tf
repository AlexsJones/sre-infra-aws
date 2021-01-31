

module "cluster" {
  source = "./modules/cluster"
}

module "deployments" {
  source = "./modules/deployments"

  aws_acm_certificate = module.cluster.aws_acm_certificate
  dns_base_domain     = module.cluster.dns_base_domain
  cluster_token       = module.cluster.cluster_token
  cluster_cert        = module.cluster.cluster_cert
  cluster_endpoint    = module.cluster.cluster_endpoint
  dns_base_domain_id  = module.cluster.dns_base_domain_id
  elb_zone_id         = module.cluster.elb_zone_id
  region              = module.cluster.region
  kubeconfig_filename = module.cluster.kubeconfig_filename
}
