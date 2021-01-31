terraform {
  backend "s3" {
    bucket               = "sre-infra-aws-cloud-skunkworks"
    key                  = "tf-state.json"
    region               = "eu-west-2"
    workspace_key_prefix = "environment"
  }
}
