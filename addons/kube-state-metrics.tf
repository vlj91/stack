resource "kubernetes_namespace" "kube-state-metrics" {
  metadata {
    name = "kube-state-metrics"
  }
}

resource "helm_release" "kube-state-metrics" {
  name       = "kube-state-metrics"
  chart      = "kube-state-metrics"
  repository = local.helm_repo["stable"]
  namespace  = kubernetes_namespace.kube-state-metrics.metadata.0.name

  set {
    name  = "podSecurityPolicy.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.monitor.enabled"
    value = "true"
  }
}