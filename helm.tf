resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  wait            = false # Non blocca Terraform in attesa dei pod
  timeout         = 900   # Aumenta l'attesa per la comunicazione iniziale
  cleanup_on_fail = true  # Se va in errore, ripulisce automaticamente la release

  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }
}