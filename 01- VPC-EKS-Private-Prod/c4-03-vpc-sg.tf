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