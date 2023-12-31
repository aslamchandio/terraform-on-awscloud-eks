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