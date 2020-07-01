resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  chart      = "prometheus"
  repository = local.helm_repo["stable"]
  namespace  = kubernetes_namespace.prometheus.metadata.0.name
}