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