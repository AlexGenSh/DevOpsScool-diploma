terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = "~> 1.0"
}

provider "aws" {
  #shared_config_files      = ["%UserProfile%/.aws/conf"]
  #shared_credentials_files = ["%UserProfile%/.aws/creds"]
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
  default_tags {
    tags = {
      "Owner"   = "Aleksandr_Shcherbakov1@epam.com"
      "Project" = "DevOps Diploma"
    }
  }
}

#Cluster IAM role

resource "aws_iam_role" "diploma-eks-iam" {
  name = "Diploma-eks-iam"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "diploma-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.diploma-eks-iam.name
}


#Nodes IAM role

resource "aws_iam_role" "diploma-nodes-iam" {
  name = "Diploma-nodes-iam"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.diploma-nodes-iam.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.diploma-nodes-iam.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.diploma-nodes-iam.name
}

#resource "aws_iam_role_policy_attachment" "nodes-CloudWatchAgentServerPolicy" {
#  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#  role       = aws_iam_role.diploma-nodes-iam.name
#}

# Autoscale Policy

resource "aws_iam_policy" "autoscale-policy" {
  name        = "Diploma_autoscale_policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
        ]
        Effect   = "Allow"
        Resource = "*"
#        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/team1/*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "autoscale-policy-attach" {
  policy_arn = aws_iam_policy.autoscale-policy.arn
  role       = aws_iam_role.diploma-nodes-iam.name
}


#------------VPC & network-------------

resource "aws_vpc" "diploma-vpc-main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "EKS-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.diploma-vpc-main.id

  tags = {
    Name = "EKS-IGW"
  }
}

resource "aws_subnet" "public-eu-west-1a" {
  vpc_id                  = aws_vpc.diploma-vpc-main.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "Diploma-public-eu-west-1a"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/diploma-cluster" = "owned"
  }
}

resource "aws_subnet" "public-eu-west-1b" {
  vpc_id                  = aws_vpc.diploma-vpc-main.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "Diploma-public-eu-west-1b"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/diploma-cluster" = "owned"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.diploma-vpc-main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Diploma-route-table"
  }
}

resource "aws_route_table_association" "public-eu-west-1a" {
  subnet_id      = aws_subnet.public-eu-west-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-eu-west-1b" {
  subnet_id      = aws_subnet.public-eu-west-1b.id
  route_table_id = aws_route_table.public.id
}
#-----------ECR------------------------------
resource "aws_ecr_repository" "demo-repository" {
  name                 = "test-repo"
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository_policy" "demo-repo-policy" {
  repository = aws_ecr_repository.demo-repository.name
  policy     =<<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the demo repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
EOF
}

#-----------RDS------------------------------

resource "aws_db_instance" "diploma-rds-dev" {
  identifier             = "terraform-rds-dev"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  db_name                = var.db_name_dev
  username               = var.db_username_dev
  password               = var.db_password_dev
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds-dev.id]
  db_subnet_group_name   = aws_db_subnet_group.db-subnets.name

  tags = {
    Name = "Diploma-RDS-dev"
  }

}

resource "aws_db_instance" "diploma-rds-prod" {
  identifier             = "terraform-rds-prod"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  db_name                = var.db_name_prod
  username               = var.db_username_prod
  password               = var.db_password_prod
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds-prod.id]
  db_subnet_group_name   = aws_db_subnet_group.db-subnets.name


  tags = {
    Name = "Diploma-RDS-prod"
  }

}

resource "aws_db_subnet_group" "db-subnets" {
  subnet_ids = [aws_subnet.public-eu-west-1a.id, aws_subnet.public-eu-west-1b.id]

  tags = {
    Name = "Diploma-RDS-subnets"
  }
}


#-------------RDS-SG--------------------

resource "aws_security_group" "rds-dev" {
  name   = "diploma-rds-dev-sg"
  vpc_id = aws_vpc.diploma-vpc-main.id

  ingress {
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Diploma-rds-dev-sg"
  }
}

resource "aws_security_group" "rds-prod" {
  name   = "diploma-rds-prod-sg"
  vpc_id = aws_vpc.diploma-vpc-main.id

  ingress {
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Diploma-rds-prod-sg"
  }
}



#-----------EKS & nodes----------------------

resource "aws_eks_cluster" "diploma-cluster" {
  name     = "diploma-cluster"
  role_arn = aws_iam_role.diploma-eks-iam.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public-eu-west-1a.id,
      aws_subnet.public-eu-west-1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.diploma-AmazonEKSClusterPolicy]
}


resource "aws_eks_node_group" "diploma-eks-node-group" {
  cluster_name    = aws_eks_cluster.diploma-cluster.name
  node_group_name = "diploma-eks-node-group"
  node_role_arn   = aws_iam_role.diploma-nodes-iam.arn

  subnet_ids = [
    aws_subnet.public-eu-west-1a.id,
    aws_subnet.public-eu-west-1b.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }


  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}

data "aws_eks_cluster" "diploma-cluster" {
  name = aws_eks_cluster.diploma-cluster.id
}

data "aws_eks_cluster_auth" "diploma-cluster" {
  name = aws_eks_cluster.diploma-cluster.id
}
