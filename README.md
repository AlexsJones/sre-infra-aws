## sre-infra-aws

This project contains resources for SRE infrastructure to be deployed to AWS.
It sets up an EKS cluster with the appropriate resources for managing tenants of that cluster through CI/CD and automating ingress to their applciations.


Requirements:
- kubectl
- helm
- tfenv
- awscli
- eksctl


![image](images/platform.png)

## Infrastructure

```
  NAME                                                                          MONTHLY QTY  UNIT        PRICE   HOURLY COST  MONTHLY COST

  aws_route53_record.eks_domain_cert_validation_dns["*.crystalbasilica.co.uk"]
  └─ Standard queries                                                                     -  1M queries  0.4000            -             -
  Total                                                                                                                    -             -

  aws_route53_record.eks_domain_cert_validation_dns["crystalbasilica.co.uk"]
  └─ Standard queries                                                                     -  1M queries  0.4000            -             -
  Total                                                                                                                    -             -

  aws_route53_record.gitlab_minio_subdomain
  └─ Standard queries                                                                     -  1M queries  0.4000            -             -
  Total                                                                                                                    -             -

  aws_route53_record.gitlab_registry_subdomain
  └─ Standard queries                                                                     -  1M queries  0.4000            -             -
  Total                                                                                                                    -             -

  aws_route53_record.gitlab_subdomain
  └─ Standard queries                                                                     -  1M queries  0.4000            -             -
  Total                                                                                                                    -             -

  module.eks.aws_autoscaling_group.workers[0]
  └─ module.eks.aws_launch_configuration.workers[0]
     ├─ Linux/UNIX usage (on-demand, m4.large)                                        2,190  hours       0.1000       0.3000      219.0000
     ├─ EC2 detailed monitoring                                                          21  metrics     0.3000       0.0086        6.3000
     └─ root_block_device
        └─ General Purpose SSD storage (gp2)                                            300  GB-months   0.1000       0.0411       30.0000
  Total                                                                                                               0.3497      255.3000

  module.eks.aws_autoscaling_group.workers[1]
  └─ module.eks.aws_launch_configuration.workers[1]
     ├─ Linux/UNIX usage (on-demand, m4.large)                                        1,460  hours       0.1000       0.2000      146.0000
     ├─ EC2 detailed monitoring                                                          14  metrics     0.3000       0.0058        4.2000
     └─ root_block_device
        └─ General Purpose SSD storage (gp2)                                            200  GB-months   0.1000       0.0274       20.0000
  Total                                                                                                               0.2332      170.2000

  module.eks.aws_eks_cluster.this[0]
  └─ EKS cluster                                                                        730  hours       0.1000       0.1000       73.0000
  Total                                                                                                               0.1000       73.0000

  module.vpc.aws_nat_gateway.this[0]
  ├─ NAT gateway                                                                        730  hours       0.0450       0.0450       32.8500
  └─ Data processed                                                                       -  GB          0.0450            -             -
  Total                                                                                                               0.0450       32.8500

  OVERALL TOTAL (USD)                                                                                                 0.7279      531.3500
```

## Installation 

### 1. Terraform

- Creates security groups, workers, EKS, ELB and other AWS resources.
- User will be prompted to create an S3 bucket "sre-infra-aws" to hold terraform state if it does not exist.

_Check the terraform/vars.tf as it will need the domain name configured_

```
./bootstrap.sh
```

_Post cluster installation_...

### 2. AWS Load balancer controller

This load balancer controller is superior when operating within AWS.
See [here]() for details. 


1. Create IAM OIDC provider
    ```
    eksctl utils associate-iam-oidc-provider \
        --region <aws-region> \
        --cluster <your-cluster-name> \
        --approve
    ```
1. Download IAM policy for the AWS Load Balancer Controller
    ```
    curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
    ```
1. Create an IAM policy called AWSLoadBalancerControllerIAMPolicy
    ```
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam-policy.json
    ```
    Take note of the policy ARN that is returned

1. Create a IAM role and ServiceAccount for the Load Balancer controller, use the ARN from the step above
    ```
    eksctl create iamserviceaccount \
    --cluster=<cluster-name> \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
    --approve
    ```

Add the EKS repository to Helm:
```shell script
helm repo add eks https://aws.github.io/eks-charts
```

Install the TargetGroupBinding CRDs:

```shell script
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
```

Install the AWS Load Balancer controller, if not using iamserviceaccount
```shell script
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=<k8s-cluster-name>
```

### 3. Route53 configuration

//TBD

