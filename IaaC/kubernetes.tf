provider "kubernetes" {
  host                   = data.aws_eks_cluster.diploma-cluster.endpoint
  token                  = data.aws_eks_cluster_auth.diploma-cluster.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.diploma-cluster.certificate_authority.0.data)
}

# To configure kubectl run "aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)"


resource "kubernetes_namespace" "test_namespace" {
  metadata {
    name = var.test_namespace
  }
  depends_on = [aws_eks_node_group.diploma-eks-node-group]
}

resource "kubernetes_namespace" "prod_namespace" {
  metadata {
    name = var.prod_namespace
  }
    depends_on = [aws_eks_node_group.diploma-eks-node-group]
}

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



# To install Metrics Server run "kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"