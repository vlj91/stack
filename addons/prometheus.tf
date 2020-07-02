resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus-operator" {
  name = "prometheus-operator"
  chart = "prometheus-operator"
  repository = local.helm_repo["stable"]
  namespace  = kubernetes_namespace.prometheus.metadata.0.name

  set {
    name = "grafana.enabled"
    value = "false"
  }

  set {
    name = "kubeStateMetrics.enabled"
    value = "false"
  }
}