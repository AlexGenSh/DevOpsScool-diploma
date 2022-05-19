provider "kubernetes" {
  host                   = aws_eks_cluster.diploma-cluster.endpoint
#  token                  = aws_eks_cluster_auth.diploma-cluster.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.diploma-cluster.certificate_authority.0.data)
}
# To configure kubectl run "aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)"


resource "kubernetes_namespace" "flasktest" {
  metadata {
    name = var.test_namespace
  }
}

resource "kubernetes_namespace" "flaskprod" {
  metadata {
    name = var.prod_namespace
  }
}

#Deploy test env

resource "kubernetes_deployment" "deploytest" {

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
          image = "nginx:1.7.8"
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
}

#Deploy prod env

resource "kubernetes_deployment" "deployprod" {

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
          image = "nginx:1.7.8"
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
}

# To install Metrics Server run "kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"

resource "kubernetes_service" "elbtest" {

  metadata {
    name = "tf-elb-test"
    namespace = var.test_namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-access-log-enabled" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-access-log-emit-interval" = "5"
      "service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-name" = "tf-s3-bucket-for-logs"
    }

  }

  spec {
    selector = {
      app = var.test_app
    }

    port {
      port        = 5000
      target_port = 5000
    }

    type = "LoadBalancer"

  }
}

resource "kubernetes_service" "elbprod" {

  metadata {
    name = "tf-elb-prod"
    namespace = var.prod_namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-access-log-enabled" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-access-log-emit-interval" = "5"
      "service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-name" = "s3-bucket-for-logs"
    }

  }

  spec {
    selector = {
      app = var.prod_app
    }

    port {
      port        = 80
      target_port = 5000
    }

    type = "LoadBalancer"

  }
}