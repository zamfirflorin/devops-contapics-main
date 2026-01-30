terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}

resource "helm_release" "backend" {
  name              = "backend"
  chart             = "../helm/backend"
  create_namespace  = true
  namespace         = "tf-namespace"
}

resource "helm_release" "frontend" {
  name              = "frontend"
  chart             = "../helm/frontend"
  create_namespace  = true  
  namespace         = "tf-namespace"
}

resource "helm_release" "ocr" {
  name              = "ocr"
  chart             = "../helm/ocr"
  create_namespace  = true 
  namespace         = "tf-namespace"
}