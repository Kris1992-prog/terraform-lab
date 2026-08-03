# Resource per il Deployment dell'E-commerce
resource "kubernetes_deployment_v1" "ecommerce_deployment" {
  wait_for_rollout = false

  metadata {
    name = "ecommerce-deployment"
    labels = {
      app = "ecommerce"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "ecommerce"
      }
    }

    template {
      metadata {
        labels = {
          app = "ecommerce"
        }
      }

      spec {
        container {
          name              = "ecommerce-app"
          image             = "kris1992/progetto-ecommerce:${var.app_image_tag}"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 80
          }

          # --- VARIABILI D'AMBIENTE (ConfigMap) ---
          env {
            name = "DB_HOST"
            value_from {
              config_map_key_ref {
                name = "db-config"
                key  = "DB_HOST"
              }
            }
          }

          env {
            name = "DB_NAME"
            value_from {
              config_map_key_ref {
                name = "db-config"
                key  = "DB_NAME"
              }
            }
          }

          # --- VARIABILI D'AMBIENTE (Secret) ---
          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = "db-credentials"
                key  = "DB_USER"
              }
            }
          }

          env {
            name = "DB_PASS"
            value_from {
              secret_key_ref {
                name = "db-credentials"
                key  = "DB_PASS"
              }
            }
          }

          # --- READINESS PROBE ---
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 2
          }

          # --- LIVENESS PROBE ---
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 20
            period_seconds        = 20
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

# Resource per l'Ingress dell'E-commerce
resource "kubernetes_ingress_v1" "ecommerce_ingress" {
  metadata {
    name = "ecommerce-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "ecommerce.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "ecommerce-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# Resource per il Service dell'E-commerce
resource "kubernetes_service_v1" "ecommerce_service" {
  metadata {
    name = "ecommerce-service"
  }

  spec {
    type = "NodePort"

    selector = {
      app = "ecommerce"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
      node_port   = 30080
    }
  }
}

# ConfigMap per le configurazioni del Database
resource "kubernetes_config_map_v1" "db_config" {
  metadata {
    name = "db-config"
  }

  data = {
    DB_HOST = "mysql-service"
    DB_NAME = "ecommercedb"
  }
}

# Secret per le credenziali sensibili del Database
resource "kubernetes_secret_v1" "db_credentials" {
  metadata {
    name = "db-credentials"
  }

  data = {
    DB_USER = var.db_username
    DB_PASS = var.db_password
  }

  type = "Opaque"
}