terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.48.0"
    }
  }
  backend "local" {
        path = "./terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}