## sre-infra-aws

This project contains resources for SRE infrastructure to be deployed to AWS.
It sets up an EKS cluster with the appropriate resources for managing tenants of that cluster through CI/CD and automating ingress to their applciations.


Requirements:
- kubectl
- helm
- tfenv
- awscli


![image](images/platform.png)

## Infrastructure

```
NAME                                                                 MONTHLY QTY  UNIT        PRICE   HOURLY COST  MONTHLY COST

aws_route53_record.eks_domain_cert_validation_dns["*.dp-arena.com"]
└─ Standard queries                                                            -  1M queries  0.4000            -             -
Total                                                                                                           -             -

aws_route53_record.eks_domain_cert_validation_dns["dp-arena.com"]
└─ Standard queries                                                            -  1M queries  0.4000            -             -
Total                                                                                                           -             -

aws_route53_record.gitlab_minio_subdomain
└─ Standard queries                                                            -  1M queries  0.4000            -             -
Total                                                                                                           -             -

aws_route53_record.gitlab_registry_subdomain
└─ Standard queries                                                            -  1M queries  0.4000            -             -
Total                                                                                                           -             -

aws_route53_record.gitlab_subdomain
└─ Standard queries                                                            -  1M queries  0.4000            -             -
Total                                                                                                           -             -

module.eks.aws_autoscaling_group.workers[0]
└─ module.eks.aws_launch_configuration.workers[0]
   ├─ Linux/UNIX usage (on-demand, m4.large)                               2,190  hours       0.1000       0.3000      219.0000
   ├─ EBS-optimized usage                                                  2,190  hours       0.0000       0.0000        0.0000
   ├─ EC2 detailed monitoring                                                 21  metrics     0.3000       0.0086        6.3000
   └─ root_block_device
      └─ General Purpose SSD storage (gp2)                                   300  GB-months   0.1000       0.0411       30.0000
Total                                                                                                      0.3497      255.3000

module.eks.aws_eks_cluster.this[0]
└─ EKS cluster                                                               730  hours       0.1000       0.1000       73.0000
Total                                                                                                      0.1000       73.0000

module.vpc.aws_nat_gateway.this[0]
├─ NAT gateway                                                               730  hours       0.0450       0.0450       32.8500
└─ Data processed                                                              -  GB          0.0450            -             -
Total                                                                                                      0.0450       32.8500

OVERALL TOTAL (USD)                                                                                        0.4947      361.1500
```

## Installation

0.  Modify domain name and values in `terraform/backend.tf` and `terraform/common_vars.tf`.
1. `aws s3 mb s3://sre-infra-aws-cloud-skunkworks --region <YOUR_REGION>`
2. `cd terraform && terraform apply`
3. `aws eks --region <YOUR_REGION> update-kubeconfig --name sre-infra`


### Post Installation



1. You might possibly find that disabling source-dest checks improves connectivity along with increasing health check timeouts (This [issue](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1931)) .
```
aws ec2 modify-instance-attribute --instance-id i-1234567890abcdef0 --source-dest-check "{\"Value\": false}"
```
2. Gitlab ingress will expect additional annotations to load the ACM certificate and terminate TLS at the ELB.

```
kubectl annotate svc/gitlab-nginx-ingress-controller -n gitlab service.beta.kubernetes.io/aws-load-balancer-backend-protocol=http --overwrite
kubectl annotate svc/gitlab-nginx-ingress-controller -n gitlab service.beta.kubernetes.io/aws-load-balancer-ssl-ports=https --overwrite
kubectl patch svc gitlab-nginx-ingress-controller -n gitlab --patch "$(cat kubernetes/patches/gitlab-svc.yaml)"
kubectl annotate svc/gitlab-nginx-ingress-controller -n gitlab service.beta.kubernetes.io/aws-load-balancer-ssl-cert "$(terraform output cert_id | sed -e 's/^"//' -e 's/"$//')" --overwrite
```
