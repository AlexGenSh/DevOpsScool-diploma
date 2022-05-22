resource "kubernetes_deployment" "testdeploy" {

  lifecycle {
    ignore_changes = [spec,]
  }

  metadata {
    name = var.test_app
    namespace = var.test_namespace
    labels = {
      app = var.test_app
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.test_app
      }
    }

    template {
      metadata {
        labels = {
          app = var.test_app
        }
      }

      spec {
        container {
          image = var.image_init
          name  = var.test_app

          resources {
            limits = {
              cpu    = "500m"
              memory = "100Mi"
            }
            requests = {
              cpu    = "150m"
              memory = "50Mi"
            }
          }

          env {
              name  = "DB_ADMIN_USERNAME"
              value = var.db_username_dev
          }
          env {
            name  = "DB_ADMIN_PASSWORD"
            value = var.db_password_dev
          }
          env {
              name  = "DB_URL"
              value = aws_db_instance.diploma-rds-dev.address
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.test_namespace]
}


resource "kubernetes_deployment" "proddeploy" {

  lifecycle {
    ignore_changes = [spec,]
  }

  metadata {
    name = var.prod_app
    namespace = var.prod_namespace
    labels = {
      app = var.prod_app
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.prod_app
      }
    }

    template {
      metadata {
        labels = {
          app = var.prod_app
        }
      }

      spec {
        container {
          image = var.image_init
          name  = var.prod_app

          resources {
            limits = {
              cpu    = "500m"
              memory = "100Mi"
            }
            requests = {
              cpu    = "150m"
              memory = "50Mi"
            }
          }

          env {
              name  = "DB_ADMIN_USERNAME"
              value = var.db_username_prod
          }
          env {
            name  = "DB_ADMIN_PASSWORD"
            value = var.db_password_prod
          }
          env {
              name  = "DB_URL"
              value = aws_db_instance.diploma-rds-prod.address
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.prod_namespace]
}