# Day 096: Create EC2 Instance Using Terraform
# Path: /home/bob/terraform/main.tf

# Get default VPC for security group reference
data "aws_vpc" "default" {
  default = true
}

# Get default security group from default VPC
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# Create RSA key pair for EC2 instance access
resource "aws_key_pair" "datacenter_kp" {
  key_name   = "datacenter-kp"
  public_key = tls_private_key.datacenter_key.public_key_openssh

  tags = {
    Name = "datacenter-kp"
  }
}

# Generate RSA private key
resource "tls_private_key" "datacenter_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create EC2 instance
resource "aws_instance" "datacenter_ec2" {
  ami                    = "ami-0c101f26f147fa7fd"  # Amazon Linux
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.datacenter_kp.key_name
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    Name = "datacenter-ec2"
  }
}

# Output the private key for SSH access (for development only)
output "private_key_pem" {
  value     = tls_private_key.datacenter_key.private_key_pem
  sensitive = true
}

# Output instance details
output "instance_id" {
  value = aws_instance.datacenter_ec2.id
}

output "instance_public_ip" {
  value = aws_instance.datacenter_ec2.public_ip
}

output "instance_public_dns" {
  value = aws_instance.datacenter_ec2.public_dns
}

output "ssh_connection_command" {
  value = "ssh -i datacenter-kp.pem ec2-user@${aws_instance.datacenter_ec2.public_ip}"
}