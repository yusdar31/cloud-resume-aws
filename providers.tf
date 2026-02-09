terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # CloudFront butuh sertifikat SSL dari us-east-1
}

# Provider alias untuk ACM certificate (harus di us-east-1 untuk CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
