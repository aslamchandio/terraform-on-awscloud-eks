# Design a 3 Tier AWS VPC with NAT Gateways using Terraform

## Step-01: Introduction
- Understand about Terraform Modules
- Create VPC using `Terraform Modules`
- Define `Input Variables` for VPC module and reference them in VPC Terraform Module
- Define `local values` and reference them in VPC Terraform Module
- Create `terraform.tfvars` to load variable values by default from this file
- Create `vpc.auto.tfvars` to load variable values by default from this file related to a VPC 
- Define `Output Values` for VPC

## Step-02: v1-vpc-module
### Step-02-01: How to make a decision of using the public Registry module?
1. Understand about [Terraform Registry and Modules](https://registry.terraform.io/)
2. We are going to use a [VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) from Terraform Public Registry
3. Understand about Authenticity of a module hosted on Public Terraform Registry with [HashiCorp Verified Tag](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
4. Review the download rate for that module
5. Review the latest versions and [release history](https://github.com/terraform-aws-modules/terraform-aws-vpc/releases) of that module
6. Review our feature needs when using that module and ensure if our need is satisfied use the module else use the standard terraform resource definition appraoch. 
7. Review module inputs, outputs and dependencies too. 

## Step-03: Version Constraints in Terraform with Modules
- [Terraform Version Constraints](https://www.terraform.io/docs/language/expressions/version-constraints.html)
- For modules locking to the exact version is recommended to ensure there will not be any major breakages in production
- When depending on third-party modules, require specific versions to ensure that updates only happen when convenient to you
- For modules maintained within your organization, specifying version ranges may be appropriate if semantic versioning is used consistently or if there is a well-defined release process that avoids unwanted updates.
- [Review and understand this carefully](https://www.terraform.io/docs/language/expressions/version-constraints.html#terraform-core-and-provider-versions)

## Step-04: v2-vpc-module-standardized - Standardized and Generalized
- In the next series of steps we are going to standardize the VPC configuration
- c1-provider.tf
```t
# Terraform Block
terraform {
  required_version = "~> 1.6.0" # which means any version equal & above 0.14 like 0.15, 0.16 etc and < 1.xx
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0"
    }
  }

# Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "aslam-terraform-aws-eks"
    key    = "dev/vpc-terraform/terraform.tfstate"
    region = "us-east-1" 
 
    # For State Locking
    dynamodb_table = "vpc-terraform"    
  }    
}  
# Provider Block
provider "aws" {
  #profile = "default"
  region  = var.aws_region
}

/*
Note-1:  AWS Credentials Profile (profile = "default") configured on your local desktop terminal  
$HOME/.aws/credentials
*/

```
## Step-05: c2-generic-variables.tf
```t

# Input Variables

# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "us-east-1"  
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "dev"
}
# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type = string
  default = "it"
}

```

## Step-06: c3-local-values.tf
- Understand about [Local Values](https://www.terraform.io/docs/language/values/locals.html)
```t
# Define Local Values in Terraform
locals {
  owners = var.business_divsion
  environment = var.environment
  name = "${var.business_divsion}-${var.environment}"
  common_tags = {
    owners = local.owners
    environment = local.environment     
  }
# Add additional local value
  eks_cluster_name = "${local.name}-${var.cluster_name}"  

}
```

## Step-07: c4-01-vpc-variables.tf
```t
# VPC Input Variables

# VPC Name
variable "vpc_name" {
  description = "VPC Name"
  type = string 
  default = "myvpc"
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type = string 
  default = "192.168.0.0/16"
}

# VPC Availability Zones
/*
variable "vpc_availability_zones" {
  description = "VPC Availability Zones"
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}
*/

# VPC Public Subnets
variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type = list(string)
  default = ["192.168.1.0/24", "192.168.3.0/24", "192.168.3.0/24"]
}

# VPC Private Subnets
variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type = list(string)
  default = ["192.168.2.0/24", "192.168.4.0/24", "192.168.6.0/24"]
}

# VPC Database Subnets
variable "vpc_database_subnets" {
  description = "VPC Database Subnets"
  type = list(string)
  default = ["192.168.11.0/24", "192.168.12.0/24", "192.168.13.0/24"]
}

# VPC Create Database Subnet Group (True / False)
variable "vpc_create_database_subnet_group" {
  description = "VPC Create Database Subnet Group"
  type = bool
  default = true 
}

# VPC Create Database Subnet Route Table (True or False)
variable "vpc_create_database_subnet_route_table" {
  description = "VPC Create Database Subnet Route Table"
  type = bool
  default = true   
}

  
# VPC Enable NAT Gateway (True or False) 
variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type = bool
  default = true  
}

# VPC Single NAT Gateway (True or False)
variable "vpc_single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type = bool
  default = true
}
```
## Step-08: c4-02-vpc-module.tf
```t
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
```
## Step-9: c4-03-vpc-sg.tf
```t
# Resource: Security Group
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Public SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    
      description = "Allow for Linux Bastion Host"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["39.51.7.206/32"]
    }

   ingress {
    
      description = "Allow for Windows Bastion Host"
      from_port        = 3389
      to_port          = 3389
      protocol         = "tcp"
      cidr_blocks      = ["39.51.7.206/32"]
    } 

     ingress {
    
      description = "Allow for Windows Bastion Host"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    } 

     ingress {
    
      description = "Allow for Windows Bastion Host"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    } 
 
  egress { 
     
      description = "Outbound Allowed"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      
  }

    tags = {
    Name = "${local.name}-public_sg"
  }
}

# Resource: Security Group
resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Private SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    
      description = "Allow for Linux Bastion Host"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["192.168.0.0/16"]
    }

   ingress {
    
      description = "Allow for Windows Bastion Host"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["192.168.0.0/16"]
    } 
 
  egress { 
     
      description = "Outbound Allowed"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      
  }

    tags = {
    Name = "${local.name}-private_sg"
  }
}

resource "aws_security_group" "control_plan_sg" {
  name        = "controlplan_sg"
  description = "Control PLan SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    
      description = "Allow for API-Server"
      from_port        = 6443
      to_port          = 6443
      protocol         = "tcp"
      cidr_blocks      = ["192.168.0.0/16"]
    }

   ingress {
    
      description = "Allow for ETCD Database"
      from_port        = 2379
      to_port          = 2380
      protocol         = "tcp"
      cidr_blocks      = ["192.168.0.0/16"]
    } 

    ingress {
    
      description = "Allow for Kubelet-Scheduler-ControlManager"
      from_port        = 10250
      to_port          = 10252
      protocol         = "tcp"
      cidr_blocks      = ["192.168.0.0/16"]
    } 
  

  egress { 
     
      description = "Outbound Allowed"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      
    }
  

  tags = {
    Name = "${local.name}-controlplan_sg"
  }
}


resource "aws_security_group" "worker_node_sg" {
  name        = "workernode-sg"
  description = "Worker Node SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    
      description = "SSH into Worker Node"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  ingress {
    
      description = "Allow Kubelet"
      from_port        = 10250
      to_port          = 10250
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  ingress {
    
      description = "Allow for Services"
      from_port        = 30000
      to_port          = 32767
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }  



  egress { 
     
      description = "Outbound Allowed"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      
    }
  

  tags = {
    Name = "${local.name}-workernode-sg"
  }
}

```

## Step-10: c4-04-vpc-outputs.tf
```t
# VPC Output Values

# VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# VPC CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# VPC Private Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

# VPC Public Subnets
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# VPC Database Subnets
output "database_subnets" {
  description = "List of IDs of Database subnets"
  value       = module.vpc.database_subnets
}

# VPC NAT gateway Public IP
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

# VPC AZs
output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.vpc.azs
}

output "public_sg" {
  value = aws_security_group.public_sg.id
}
 
output "private_sg" {
  value = aws_security_group.private_sg.id
}

output "control_plan_sg" {
  value = aws_security_group.control_plan_sg.id
}

output "worker_node_sg" {
  value = aws_security_group.worker_node_sg.id
}
```

## Step-11: c5-01-ami-datasource.tf
```t
#Get latest Ubuntu Linux Jammy 22.04 AMI
data "aws_ami" "ubuntulinux22" {
  most_recent = true
  owners = [ "099720109477" ]
  filter {
    name = "name"
    values = [ "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}

```

## Step-12: c5-02-ec2-instance.tf
```t
# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"
  # insert the 10 required variables here
  name = "${local.name}-bastionhost"
  ami = data.aws_ami.ubuntulinux22.id
  instance_type = "t2.micro"
  user_data = file("${path.module}/bastion.sh")
  key_name = "AWSKey"
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true 
  vpc_security_group_ids = [ aws_security_group.public_sg.id ]   
  
}

```
## Step-13: c5-03-ec2-outputs.tf
```t
# AWS EC2 Instance Terraform Outputs
# Public EC2 Instances - Bastion Host
output "ec2_public_instance_ids" {
  description = "List of IDs of instances"
  value       = module.ec2_public.id
}
output "ec2_public_ip" {
  description = "List of Public ip address assigned to the instances"
  value       = module.ec2_public.public_ip
}

```
## Step-14: c6-eks-variables.tf
```t
# EKS Cluster Input Variables
variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
  default     = "ekscluster1"
}

```
## Step-15: eks-auto-tfvars
```t
cluster_name = "ekscluster1"

```
## Step-16: terraform.tfvars
```t
# Generic Variables
aws_region = "us-east-1"   
environment = "dev"
business_divsion = "it"

```
## Step-17: vpc.auto.tfvars
```t
# VPC Variables
vpc_name = "myvpc"
vpc_cidr_block = "192.168.0.0/16"
#vpc_availability_zones = ["us-east-1a", "us-east-1b", "us-east-1d"]
vpc_public_subnets = ["192.168.1.0/24", "192.168.3.0/24", "192.168.5.0/24"]
vpc_private_subnets = ["192.168.2.0/24", "192.168.4.0/24", "192.168.6.0/24"]
vpc_database_subnets= ["192.168.11.0/24", "192.168.12.0/24", "192.168.13.0/24"]
vpc_create_database_subnet_group = true 
vpc_create_database_subnet_route_table = true   
vpc_enable_nat_gateway = true  
vpc_single_nat_gateway = true
```
## Step-18: bastion.sh
```t
#!/bin/bash
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y
sudo hostnamectl set-hostname Bastion-Host
sudo ufw allow proto tcp from any to any port 22,80,443
sudo apt install zip unzip wget net-tools vim nano htop -y
sudo echo 'y' | sudo ufw enable

```
## Step-19: Execute Terraform Commands
```t
# Working Folder
terraform-manifests

# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform plan
terraform plan

# Terraform Apply
terraform apply -auto-approve
Observation:
1) Verify VPC
2) Verify Subnets
3) Verify IGW
4) Verify Public Route for Public Subnets
5) Verify no public route for private subnets
6) Verify NAT Gateway and Elastic IP for NAT Gateway
7) Verify NAT Gateway route for Private Subnets
8) Verify no public route or no NAT Gateway route to Database Subnets
9) Verify Tags
```

## Step-20: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve

# Delete Files
rm -rf .terraform*
rm -rf terraform.tfstate*
```


