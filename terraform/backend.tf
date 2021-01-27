terraform {
  backend "s3" {
    bucket               = "sre-infra-aws"
    key                  = "tf-state.json"
    region               = "us-east-1"
    workspace_key_prefix = "dp-arena"
  }
}
