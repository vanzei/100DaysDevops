# Day 094: Create VPC Using Terraform - Resources Guide

## Table of Contents
1. [What is Amazon VPC?](#what-is-amazon-vpc)
2. [VPC Core Components](#vpc-core-components)
3. [VPC Architecture Deep Dive](#vpc-architecture-deep-dive)
4. [CIDR Blocks and IP Addressing](#cidr-blocks-and-ip-addressing)
5. [Terraform for AWS Infrastructure](#terraform-for-aws-infrastructure)
6. [Challenge Implementation](#challenge-implementation)
7. [Production vs Challenge Differences](#production-vs-challenge-differences)
8. [Best Practices](#best-practices)
9. [Real-World Implementation Patterns](#real-world-implementation-patterns)
10. [Troubleshooting Guide](#troubleshooting-guide)

## What is Amazon VPC?

### Definition
Amazon Virtual Private Cloud (VPC) is a virtual network dedicated to your AWS account. It provides complete control over your virtual networking environment, including resource placement, connectivity, and security.

### Key Characteristics
- **Isolated Network**: Logically isolated from other virtual networks in AWS
- **Customizable**: Full control over IP address ranges, subnets, route tables, and gateways
- **Secure**: Built-in security features with security groups and network ACLs
- **Scalable**: Can span multiple Availability Zones within a region
- **Connected**: Can connect to on-premises networks, other VPCs, and the internet

### Why Use VPC?
1. **Security**: Network isolation and granular access control
2. **Compliance**: Meet regulatory requirements for data isolation
3. **Performance**: Optimized network performance within the VPC
4. **Flexibility**: Design network topology to meet specific requirements
5. **Cost Control**: Better resource management and cost optimization

## VPC Core Components

### 1. VPC (Virtual Private Cloud)
```
Purpose: The foundational network container
Function: Defines the overall network boundary and IP address space
Analogy: Like a private office building with its own address range
```

### 2. Subnets
```
Purpose: Subdivisions of the VPC network
Function: Segment the VPC into smaller networks for organization and security
Types:
  - Public Subnets: Direct internet access via Internet Gateway
  - Private Subnets: No direct internet access
  - Database Subnets: Isolated subnets for databases
Analogy: Like floors or departments within the office building
```

### 3. Internet Gateway (IGW)
```
Purpose: Provides internet connectivity
Function: Allows communication between VPC and the internet
Characteristics:
  - Horizontally scaled, redundant, highly available
  - One per VPC
  - Must be attached to VPC and route table
Analogy: Like the main entrance/exit of the building
```

### 4. Route Tables
```
Purpose: Network traffic routing rules
Function: Determines where network traffic is directed
Types:
  - Main Route Table: Default for all subnets
  - Custom Route Tables: Specific routing for subnets
Analogy: Like a building directory showing how to reach different areas
```

### 5. NAT Gateway/Instance
```
Purpose: Outbound internet access for private subnets
Function: Allows private resources to access internet without being directly accessible
Characteristics:
  - NAT Gateway: Managed service (recommended)
  - NAT Instance: Self-managed EC2 instance
Analogy: Like a secure mail room that can send but not receive direct mail
```

### 6. Security Groups
```
Purpose: Instance-level firewall
Function: Controls inbound and outbound traffic at the instance level
Characteristics:
  - Stateful: Response traffic automatically allowed
  - Allow rules only (no deny rules)
  - Applied to ENIs (Elastic Network Interfaces)
Analogy: Like a security guard at each office door
```

### 7. Network ACLs (Access Control Lists)
```
Purpose: Subnet-level firewall
Function: Controls traffic at the subnet boundary
Characteristics:
  - Stateless: Must explicitly allow both request and response traffic
  - Allow and deny rules
  - Applied to all instances in the subnet
Analogy: Like building-wide security policies
```

### 8. VPC Endpoints
```
Purpose: Private connectivity to AWS services
Function: Access AWS services without going through the internet
Types:
  - Interface Endpoints: ENI with private IP
  - Gateway Endpoints: Route table entries (S3, DynamoDB)
Analogy: Like private dedicated lines to service providers
```

## VPC Architecture Deep Dive

### Basic VPC Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     AWS Region (us-east-1)                  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                VPC (10.0.0.0/16)                     │  │
│  │                                                       │  │
│  │  ┌─────────────────┐    ┌─────────────────┐          │  │
│  │  │  Public Subnet  │    │  Private Subnet │          │  │
│  │  │  10.0.1.0/24    │    │  10.0.2.0/24    │          │  │
│  │  │  AZ: us-east-1a │    │  AZ: us-east-1b │          │  │
│  │  │                 │    │                 │          │  │
│  │  │  ┌───────────┐  │    │  ┌───────────┐  │          │  │
│  │  │  │    EC2    │  │    │  │    RDS    │  │          │  │
│  │  │  │ Instance  │  │    │  │ Database  │  │          │  │
│  │  │  └───────────┘  │    │  └───────────┘  │          │  │
│  │  └─────────────────┘    └─────────────────┘          │  │
│  │           │                       │                  │  │
│  │           │              ┌─────────────────┐         │  │
│  │           │              │   NAT Gateway   │         │  │
│  │           │              │   (in public)   │         │  │
│  │           │              └─────────────────┘         │  │
│  │           │                       │                  │  │
│  │  ┌─────────────────┐              │                  │  │
│  │  │ Internet Gateway│──────────────┘                  │  │
│  │  └─────────────────┘                                 │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                         ┌─────────┐
                         │Internet │
                         └─────────┘
```

### Multi-AZ Production Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AWS Region (us-east-1)                            │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        VPC (10.0.0.0/16)                             │  │
│  │                                                                       │  │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    │  │
│  │  │   AZ-1a Subnets │    │   AZ-1b Subnets │    │   AZ-1c Subnets │    │  │
│  │  │                 │    │                 │    │                 │    │  │
│  │  │ Public: 10.0.1.0│    │ Public: 10.0.4.0│    │ Public: 10.0.7.0│    │  │
│  │  │ Private:10.0.2.0│    │ Private:10.0.5.0│    │ Private:10.0.8.0│    │  │
│  │  │ DB: 10.0.3.0/24 │    │ DB: 10.0.6.0/24 │    │ DB: 10.0.9.0/24 │    │  │
│  │  │                 │    │                 │    │                 │    │  │
│  │  │  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │    │  │
│  │  │  │    ALB    │  │    │  │    ALB    │  │    │  │    ALB    │  │    │  │
│  │  │  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │    │  │
│  │  │  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │    │  │
│  │  │  │    EC2    │  │    │  │    EC2    │  │    │  │    EC2    │  │    │  │
│  │  │  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │    │  │
│  │  │  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │    │  │
│  │  │  │    RDS    │  │    │  │RDS Replica│  │    │  │RDS Replica│  │    │  │
│  │  │  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │    │  │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────┘    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## CIDR Blocks and IP Addressing

### Understanding CIDR Notation

CIDR (Classless Inter-Domain Routing) notation represents IP address ranges using format: `IP_ADDRESS/PREFIX_LENGTH`

#### CIDR Examples and Capacity

| CIDR Block | Available IPs | Subnet Mask | Use Case |
|------------|---------------|-------------|----------|
| 10.0.0.0/16 | 65,536 | 255.255.0.0 | Large VPC |
| 10.0.0.0/24 | 256 | 255.255.255.0 | Single subnet |
| 10.0.0.0/28 | 16 | 255.255.255.240 | Small subnet |
| 172.16.0.0/12 | 1,048,576 | 255.240.0.0 | Very large VPC |
| 192.168.0.0/16 | 65,536 | 255.255.0.0 | Home/office networks |

### AWS Reserved IP Addresses

AWS reserves 5 IP addresses in each subnet:
- **First IP**: Network address (10.0.1.0)
- **Second IP**: VPC router (10.0.1.1)
- **Third IP**: DNS server (10.0.1.2)
- **Fourth IP**: Future use (10.0.1.3)
- **Last IP**: Broadcast address (10.0.1.255)

### VPC CIDR Planning

#### Small Organization (< 1000 instances)
```
VPC: 10.0.0.0/16 (65,536 IPs)
├── Public Subnet 1: 10.0.1.0/24 (256 IPs)
├── Public Subnet 2: 10.0.2.0/24 (256 IPs)
├── Private Subnet 1: 10.0.10.0/24 (256 IPs)
├── Private Subnet 2: 10.0.11.0/24 (256 IPs)
├── Database Subnet 1: 10.0.20.0/24 (256 IPs)
└── Database Subnet 2: 10.0.21.0/24 (256 IPs)
```

#### Large Organization (> 10,000 instances)
```
VPC: 10.0.0.0/8 (16,777,216 IPs)
├── Production: 10.1.0.0/16
├── Staging: 10.2.0.0/16
├── Development: 10.3.0.0/16
└── Management: 10.4.0.0/16
```

## Terraform for AWS Infrastructure

### What is Terraform?

Terraform is an Infrastructure as Code (IaC) tool that allows you to define and provision infrastructure using declarative configuration files.

### Key Terraform Concepts

#### 1. Providers
```hcl
# AWS Provider configuration
provider "aws" {
  region = "us-east-1"
}
```

#### 2. Resources
```hcl
# VPC Resource
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "main-vpc"
  }
}
```

#### 3. Data Sources
```hcl
# Fetch existing data
data "aws_availability_zones" "available" {
  state = "available"
}
```

#### 4. Variables
```hcl
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}
```

#### 5. Outputs
```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

### Terraform Workflow

1. **terraform init**: Initialize working directory
2. **terraform plan**: Preview changes
3. **terraform apply**: Apply changes
4. **terraform destroy**: Remove infrastructure

## Challenge Implementation

### Challenge Requirements Analysis

Based on the challenge description:
- **Resource**: VPC named "nautilus-vpc"
- **Region**: us-east-1
- **CIDR**: Any IPv4 CIDR block (we'll use 10.0.0.0/16)
- **File**: main.tf (single file)
- **Directory**: /home/bob/terraform

### Basic VPC Configuration

```hcl
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "nautilus_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "nautilus-vpc"
  }
}
```

### Enhanced Configuration with Best Practices

```hcl
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "nautilus_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "nautilus-vpc"
    Environment = "production"
    Project     = "nautilus"
    ManagedBy   = "terraform"
  }
}

# Output the VPC ID for reference
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.nautilus_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.nautilus_vpc.cidr_block
}
```

## Production vs Challenge Differences

### Challenge Implementation (Minimal)
```hcl
# Simple VPC creation - meets requirements
resource "aws_vpc" "nautilus_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "nautilus-vpc"
  }
}
```

### Production Implementation (Comprehensive)

#### 1. Complete VPC with Subnets
```hcl
# VPC
resource "aws_vpc" "nautilus_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "nautilus-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "nautilus_igw" {
  vpc_id = aws_vpc.nautilus_vpc.id
  
  tags = {
    Name = "nautilus-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.nautilus_vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-subnet-${count.index + 1}"
    Type = "public"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.nautilus_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "private-subnet-${count.index + 1}"
    Type = "private"
  }
}
```

#### 2. Security and Monitoring
```hcl
# VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.nautilus_vpc.id
}

# Default Security Group Rules
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.nautilus_vpc.id
  
  # Remove all default rules
  ingress = []
  egress  = []
  
  tags = {
    Name = "default-sg-restricted"
  }
}
```

#### 3. Multi-Environment Support
```hcl
# Variables for different environments
variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# Environment-specific CIDR blocks
locals {
  vpc_cidrs = {
    dev     = "10.1.0.0/16"
    staging = "10.2.0.0/16"
    prod    = "10.0.0.0/16"
  }
}

resource "aws_vpc" "nautilus_vpc" {
  cidr_block = local.vpc_cidrs[var.environment]
  # ... rest of configuration
}
```

## Best Practices

### 1. CIDR Planning Best Practices

#### Do's:
- **Plan for Growth**: Use larger CIDR blocks than initially needed
- **Avoid Overlaps**: Ensure CIDR blocks don't overlap with existing networks
- **Standard Ranges**: Use RFC 1918 private ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- **Consistent Patterns**: Use consistent numbering schemes across environments

#### Don'ts:
- **Too Small**: Don't use /24 or smaller for VPC CIDR
- **Random Ranges**: Don't use random CIDR blocks without planning
- **Overlapping**: Don't create overlapping CIDR blocks

### 2. Security Best Practices

#### Network Security:
```hcl
# Enable VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.nautilus_vpc.id
}

# Restrict default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.nautilus_vpc.id
  
  ingress = []
  egress  = []
}
```

#### Access Control:
```hcl
# Network ACLs for additional security
resource "aws_network_acl" "private_nacl" {
  vpc_id     = aws_vpc.nautilus_vpc.id
  subnet_ids = aws_subnet.private_subnets[*].id
  
  # Allow inbound from VPC
  ingress {
    rule_no    = 100
    protocol   = "-1"
    cidr_block = aws_vpc.nautilus_vpc.cidr_block
    from_port  = 0
    to_port    = 0
    action     = "allow"
  }
  
  # Allow outbound to internet (for updates)
  egress {
    rule_no    = 100
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    action     = "allow"
  }
}
```

### 3. Terraform Best Practices

#### File Organization:
```
terraform/
├── main.tf          # Main resources
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Provider versions
├── terraform.tfvars # Variable values
└── modules/         # Reusable modules
    └── vpc/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

#### State Management:
```hcl
# Configure remote state
terraform {
  backend "s3" {
    bucket = "nautilus-terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
    
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
```

#### Version Constraints:
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### 4. Cost Optimization

#### Resource Tagging:
```hcl
# Consistent tagging for cost allocation
locals {
  common_tags = {
    Project     = "nautilus"
    Environment = var.environment
    ManagedBy   = "terraform"
    CostCenter  = var.cost_center
    Owner       = var.owner
  }
}

resource "aws_vpc" "nautilus_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = merge(local.common_tags, {
    Name = "nautilus-vpc"
  })
}
```

#### Resource Lifecycle:
```hcl
resource "aws_vpc" "nautilus_vpc" {
  cidr_block = "10.0.0.0/16"
  
  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion
    
    ignore_changes = [
      tags["LastModified"]  # Ignore external tag changes
    ]
  }
}
```

## Real-World Implementation Patterns

### 1. Hub and Spoke Architecture
```hcl
# Central Hub VPC
resource "aws_vpc" "hub_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "hub-vpc"
    Type = "hub"
  }
}

# Spoke VPCs
resource "aws_vpc" "spoke_vpcs" {
  count      = length(var.spoke_environments)
  cidr_block = var.spoke_cidrs[count.index]
  
  tags = {
    Name = "${var.spoke_environments[count.index]}-vpc"
    Type = "spoke"
  }
}

# VPC Peering connections
resource "aws_vpc_peering_connection" "hub_to_spoke" {
  count       = length(aws_vpc.spoke_vpcs)
  vpc_id      = aws_vpc.hub_vpc.id
  peer_vpc_id = aws_vpc.spoke_vpcs[count.index].id
  auto_accept = true
  
  tags = {
    Name = "hub-to-${var.spoke_environments[count.index]}"
  }
}
```

### 2. Multi-Account Architecture
```hcl
# Cross-account VPC peering
resource "aws_vpc_peering_connection" "cross_account" {
  vpc_id        = aws_vpc.nautilus_vpc.id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = var.peer_account_id
  peer_region   = var.peer_region
  
  tags = {
    Name = "cross-account-peering"
  }
}
```

### 3. Transit Gateway Integration
```hcl
# Transit Gateway for complex networking
resource "aws_ec2_transit_gateway" "nautilus_tgw" {
  description                     = "Nautilus Transit Gateway"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  tags = {
    Name = "nautilus-tgw"
  }
}

# Attach VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "nautilus_attachment" {
  subnet_ids         = aws_subnet.private_subnets[*].id
  transit_gateway_id = aws_ec2_transit_gateway.nautilus_tgw.id
  vpc_id             = aws_vpc.nautilus_vpc.id
  
  tags = {
    Name = "nautilus-tgw-attachment"
  }
}
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. CIDR Block Conflicts
**Problem**: Error creating VPC due to overlapping CIDR blocks
```
Error: InvalidVpc.Range: The CIDR '10.0.0.0/16' conflicts with another subnet
```

**Solution**:
```hcl
# Use unique CIDR blocks
locals {
  vpc_cidrs = {
    prod    = "10.0.0.0/16"
    staging = "10.1.0.0/16"
    dev     = "10.2.0.0/16"
  }
}
```

#### 2. Provider Authentication Issues
**Problem**: AWS credentials not configured
```
Error: No valid credential sources found for AWS Provider
```

**Solution**:
```bash
# Configure AWS credentials
aws configure

# Or use environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Or use IAM roles (recommended for EC2)
```

#### 3. Resource Limit Exceeded
**Problem**: VPC limit reached in region
```
Error: VpcLimitExceeded: The maximum number of VPCs has been reached
```

**Solution**:
```bash
# Check current VPC usage
aws ec2 describe-vpcs --region us-east-1

# Request limit increase through AWS Support
# Or delete unused VPCs
aws ec2 delete-vpc --vpc-id vpc-12345678
```

#### 4. State File Issues
**Problem**: Terraform state corruption or conflicts
```
Error: Error acquiring the state lock
```

**Solution**:
```bash
# Force unlock (if safe)
terraform force-unlock LOCK_ID

# Or refresh state
terraform refresh

# Import existing resources if needed
terraform import aws_vpc.nautilus_vpc vpc-12345678
```

### Validation Commands

```bash
# Validate configuration
terraform validate

# Check formatting
terraform fmt -check

# Plan deployment
terraform plan

# Apply with auto-approve (use carefully)
terraform apply -auto-approve

# Show current state
terraform show

# List resources
terraform state list

# Get specific resource details
terraform state show aws_vpc.nautilus_vpc
```

### Debugging Tips

1. **Enable Detailed Logging**:
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH="./terraform.log"
```

2. **Use Local Values for Complex Logic**:
```hcl
locals {
  # Calculate subnet CIDRs dynamically
  public_subnet_cidrs = [
    for i in range(var.public_subnet_count) :
    cidrsubnet(aws_vpc.nautilus_vpc.cidr_block, 8, i)
  ]
}
```

3. **Add Validation Rules**:
```hcl
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}
```

This comprehensive guide covers everything you need to understand VPC concepts, Terraform implementation, and the differences between challenge requirements and production deployments. The next step is to create the actual Terraform configuration file for the challenge.