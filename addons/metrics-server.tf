resource "kubernetes_namespace" "metrics-server" {
  metadata {
    name = "metrics-server"
  }
}

resource "helm_release" "metrics-server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = local.helm_repo["stable"]
  namespace  = kubernetes_namespace.metrics-server.metadata.0.name

  set {
    name  = "replicas"
    value = 2
  }

  set {
    name  = "podDisruptionBudget.enabled"
    value = "true"
  }

  set {
    name  = "podDisruptionBudget.minAvailable"
    value = 50
  }

  set {
    name  = "podDisruptionBudget.maxAvailable"
    value = 200
  }

  set {
    name  = "rbac.pspEnabled"
    value = "true"
  }
}