terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

}

provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["c:\\Users\\Mikhail_Mereminskiy\\.aws\\credentials"]
  profile                  = "default"
}