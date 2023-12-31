# Terraform Block
terraform {
  required_version = "~> 1.6.0" # which means any version equal & above 0.14 like 0.15, 0.16 etc and < 1.xx
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0"
    }
  }

# Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "aslam-terraform-aws-eks"
    key    = "dev/vpc-terraform/terraform.tfstate"
    region = "us-east-1" 
 
    # For State Locking
    dynamodb_table = "vpc-terraform"    
  }    
}  
# Provider Block
provider "aws" {
  #profile = "default"
  region  = var.aws_region
}

/*
Note-1:  AWS Credentials Profile (profile = "default") configured on your local desktop terminal  
$HOME/.aws/credentials
*/

