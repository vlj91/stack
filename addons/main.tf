variable "stack_name" {
  type        = string
  description = "Stack name"
}

variable "oidc_issuer" {
  type        = string
  description = "Cluster OIDC issuer URL"
}

locals {
  helm_repo = {
    "incubator" = "https://kubernetes-charts-incubator.storage.googleapis.com"
    "stable"    = "https://kubernetes-charts.storage.googleapis.com"
  }
}