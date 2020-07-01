variable "cluster" {
  type        = string
  description = "Cluster name"
}

variable "name" {
  type        = string
  description = "Service name"
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy service into"
  default     = "default"
}

variable "replicas" {
  type        = number
  description = "Number of pods to create"
  default     = 3
}

variable "image" {
  type        = string
  description = "Docker image URL"
}

variable "container_port" {
  type        = number
  description = "Port the container runs on"
}

variable "service_port" {
  type        = number
  description = "Cluster port to expose"
  default     = 80
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    
    labels = {
      "app" = var.name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        name = var.name
        
        labels = {
          "app" = var.name
        }
      }

      spec {
        container {
          name = var.name
          image = var.image

          port {
            container_port = var.container_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace

    labels = {
      "app" = var.name
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = var.name
    }

    port {
      port        = var.service_port
      target_port = var.container_port
    }
  }
}