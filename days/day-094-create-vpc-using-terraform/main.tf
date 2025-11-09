# Day 094: Create VPC Using Terraform
# Path: /home/bob/terraform/main.tf

# Create VPC named nautilus-vpc
resource "aws_vpc" "nautilus_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "nautilus-vpc"
  }
}