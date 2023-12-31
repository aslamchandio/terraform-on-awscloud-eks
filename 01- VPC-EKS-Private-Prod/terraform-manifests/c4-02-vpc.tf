module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"
  
  # insert the 21 required variables here

  # VPC Basic Details
  #name = "${local.name}-${var.vpc_name}"
  name     = "${local.name}-${var.cluster_name}-vpc"
  cidr = var.vpc_cidr_block

  azs                 = ["us-east-1a", "us-east-1b", "us-east-1d"]
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets  

  # Database Subnets
  database_subnets = var.vpc_database_subnets
  create_database_subnet_group = var.vpc_create_database_subnet_group
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  # create_database_internet_gateway_route = true
  # create_database_nat_gateway_route = true

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway 
  single_nat_gateway = var.vpc_single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support = true
  

  # Additional Tags to Subnets
  public_subnet_tags = {
     Type = "Public Subnets"
    "kubernetes.io/role/elb" = 1    
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"          
  }
  private_subnet_tags = {
    Type = "private-subnets"
    "kubernetes.io/role/internal-elb" = 1    
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"      
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }

    tags = {
    Owner = "Aslam"
    Environment = "dev"
  }
 # Instances launched into the Public subnet should be assigned a public IP address.
  map_public_ip_on_launch = true
}

