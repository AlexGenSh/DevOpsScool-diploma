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

# To install Metrics Server run "kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"