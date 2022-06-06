locals {
  vpc_region = "us-west-2"
  hvn_region = "us-west-2"
  profile    = "aidoc"
  cluster_id = "tapuhi-aidoc-consul"
  vault_id   = "tapuhi-aidoc-vault"
  hvn_id     = "tapuhi-aidoc-hvn"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.43"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.18.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.3"
    }
  }
  backend "s3" {
    bucket         = "tapuhi-aidoc-devops-home-task"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    key            = "aws/us-west-2/CONSUL_SERVICE/terraform.tfstate"
    profile        = "aidoc"
  }
}
