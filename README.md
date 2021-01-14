## sre-infra-aws

This project contains resources for SRE infrastructure to be deployed to AWS.
It sets up an EKS cluster with the appropriate resources for managing tenants of that cluster through CI/CD and automating ingress to their applciations.


Requirements:
- kubectl
- helm
- tfenv
- awscli


![image](images/platform.png)

### Terraform

- This will depend on an existing r53 zone that is configurable at runtime e.g. "foo.com" 
- Creates security groups, workers, EKS, ELB and other AWS resources.
- User will be prompted to create an S3 bucket "sre-infra-aws" to hold terraform state if it does not exist.

```
./bootstrap.sh
```

And for deletion/cleanup

```
./destroy.sh
```