terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">=0.7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    linode = {
      source  = "linode/linode"
      version = "~> 2.31.1"
    }
  
  }
  required_version = ">= 1.4.0"
}