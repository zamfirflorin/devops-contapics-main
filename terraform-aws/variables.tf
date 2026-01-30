variable "aws_region" {
  description = "Regiunea AWS"
  type        = string
  default     = "eu-central-1"
}

variable "cluster_name" {
  description = "Numele clusterului EKS"
  type        = string
  default     = "florin_contapics"
}

variable "cluster_version" {
  description = "Versiunea Kubernetes"
  type        = string
  default     = "1.30"
}