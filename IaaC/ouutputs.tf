output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "IGW" {
  description = "IGW FQDN"
  value = aws_internet_gateway.igw.tags_all
}

output "Test_ELB" {
  description = "Test-ELB FQDN"
  value = kubernetes_service.elb-test.status[0].load_balancer[0]
}

output "Prod_ELB" {
  description = "Prod-ELB FQDN"
  value = kubernetes_service.elb-prod.status[0].load_balancer[0]
}

#output "elb_id" {
#  description = "ELB ID"
#  value = substr(resource.kubernetes_service.elb.status[0].load_balancer[0].ingress[0].hostname, 0, 32)
#}

output "db_instance_address" {
  description = "RDS FQDN"
  value = aws_db_instance.diploma-rds-dev.address
}


output "aws_eks_cluster" {
  description = "ff"
  value = aws_eks_cluster.diploma-cluster.endpoint
}


output "aws_eks_node_group" {
  description = "ff"
  value = aws_eks_node_group.diploma-eks-node-group.remote_access
}


#output "elb_prod_dns" {
#  description = "ff"
#  value = kubernetes_service.elbprod.id
#}