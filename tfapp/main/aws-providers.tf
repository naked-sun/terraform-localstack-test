provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Stack       = var.stack_name
      Environment = "Development"
    }
  }
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt or via a backend.hcl file. See
  # https://www.terraform.io/docs/backends/config.html#partial-configuration
  #  backend "s3" {}

  # Only allow this Terraform version. Note that if you upgrade to a newer version, Terraform won't allow you to use an
  # older version, so when you upgrade, you should upgrade everyone on your team and your CI servers all at once.
  required_version = "= 1.6.5"

  #  required_providers {
  #    aws = {
  #      source  = "hashicorp/aws"
  #      version = ">= 3.60.0, <= 4.22.0"
  #    }
  #  }
}
