terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # Provider AWS originale
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Nuovi provider aggiunti
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }

  # Configurazione del Remote State su S3 (Originale)
  backend "s3" {
    bucket       = "kris-tfstate-2026-894792044515-eu-south-1-an" # Il bucket creato a mano su AWS
    key          = "prod/terraform.tfstate"
    region       = "eu-south-1"
    use_lockfile = true
    encrypt      = true
  }
}

# Configurazione del Provider AWS (Originale)
provider "aws" {
  region = "eu-south-1"
}

# Configurazione del Provider Kubernetes (Nuovo)
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Configurazione del Provider Helm (Nuovo)
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

