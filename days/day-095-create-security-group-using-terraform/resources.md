# Day 095: Create Security Group Using Terraform - Resources Guide

## Table of Contents
1. [What are AWS Security Groups?](#what-are-aws-security-groups)
2. [Security Groups vs Traditional Firewalls](#security-groups-vs-traditional-firewalls)
3. [Security Group Core Concepts](#security-group-core-concepts)
4. [Network Security Architecture](#network-security-architecture)
5. [Terraform Security Group Implementation](#terraform-security-group-implementation)
6. [Challenge Implementation Analysis](#challenge-implementation-analysis)
7. [Production vs Challenge Differences](#production-vs-challenge-differences)
8. [Security Best Practices](#security-best-practices)
9. [Real-World Implementation Patterns](#real-world-implementation-patterns)
10. [Troubleshooting and Monitoring](#troubleshooting-and-monitoring)

## What are AWS Security Groups?

### Definition
AWS Security Groups act as virtual firewalls that control inbound and outbound traffic for AWS resources, primarily EC2 instances. They operate at the instance level and provide stateful packet filtering.

### Key Characteristics
- **Stateful**: Automatically allows response traffic for allowed inbound connections
- **Instance-Level**: Applied to Elastic Network Interfaces (ENIs)
- **Allow Rules Only**: Cannot create explicit deny rules (implicit deny by default)
- **Dynamic**: Can be modified without stopping instances
- **Centralized**: One security group can be applied to multiple instances

### Real-World Analogy
Think of Security Groups as **security guards for apartment buildings**:
- **Building Security**: Each building (instance) has security guards
- **Allow List**: Guards only let in pre-approved visitors (allowed traffic)
- **Two-Way Communication**: Once someone is let in, they can respond back
- **Multiple Buildings**: Same security rules can apply to multiple buildings

## Security Groups vs Traditional Firewalls

### Comparison Table

| Feature | AWS Security Groups | Traditional Firewalls |
|---------|-------------------|----------------------|
| **State Management** | Stateful (automatic return traffic) | Can be stateful or stateless |
| **Rule Types** | Allow rules only | Allow and deny rules |
| **Default Behavior** | Deny all (implicit) | Configurable default |
| **Location** | Instance-level (ENI) | Network perimeter/gateway |
| **Modification** | Real-time, no downtime | May require service restart |
| **Rule Evaluation** | All rules evaluated | First match wins (typically) |
| **Source/Destination** | IP ranges, other SGs, prefix lists | IP ranges, interfaces |

### Traditional Firewall Architecture
```
Internet → [Perimeter Firewall] → Internal Network → Servers
                    ↑
               Single point of control
```

### AWS Security Group Architecture
```
Internet → [Internet Gateway] → VPC → [Security Group] → EC2 Instance
                                      [Security Group] → EC2 Instance  
                                      [Security Group] → EC2 Instance
                                             ↑
                                    Distributed control
```

## Security Group Core Concepts

### 1. Inbound Rules (Ingress)
Controls traffic **coming into** your instances.

```hcl
# HTTP access from anywhere
ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

**Components**:
- **Protocol**: TCP, UDP, ICMP, or All
- **Port Range**: Single port or range (e.g., 80 or 8000-8080)
- **Source**: Where traffic is coming from
  - CIDR blocks (IP ranges)
  - Other security groups
  - Prefix lists

### 2. Outbound Rules (Egress)
Controls traffic **leaving** your instances.

```hcl
# HTTPS access to anywhere (for updates, API calls)
egress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

**Default Behavior**: By default, Security Groups allow all outbound traffic

### 3. Stateful Nature

```
Example: Web Server with HTTP rule

1. Client (Internet) → HTTP Request (port 80) → Web Server
   ✅ Allowed by inbound rule

2. Web Server → HTTP Response (random high port) → Client
   ✅ Automatically allowed (stateful response)
```

### 4. Security Group Referencing

```hcl
# Web servers can accept traffic from load balancer
resource "aws_security_group" "web_sg" {
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Reference another SG
  }
}
```

## Network Security Architecture

### Layer-by-Layer Security Model

```
┌─────────────────────────────────────────────────────────────────┐
│                        Internet                                  │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────┐
│                    Internet Gateway                              │
│                   (No filtering)                                │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────┐
│                         VPC                                     │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    Subnets                              │    │
│  │                                                         │    │
│  │  ┌─────────────────┐    ┌─────────────────┐            │    │
│  │  │   Network ACL   │    │   Network ACL   │            │    │
│  │  │  (Subnet-level) │    │  (Subnet-level) │            │    │
│  │  │   ┌─────────┐   │    │   ┌─────────┐   │            │    │
│  │  │   │ EC2 +   │   │    │   │ EC2 +   │   │            │    │
│  │  │   │Security │   │    │   │Security │   │            │    │
│  │  │   │ Group   │   │    │   │ Group   │   │            │    │
│  │  │   └─────────┘   │    │   └─────────┘   │            │    │
│  │  └─────────────────┘    └─────────────────┘            │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### Defense in Depth Strategy

1. **Network ACLs**: Subnet-level, stateless filtering
2. **Security Groups**: Instance-level, stateful filtering  
3. **Host-based Firewalls**: OS-level protection (iptables, Windows Firewall)
4. **Application-level**: Authentication, authorization, input validation

## Terraform Security Group Implementation

### Basic Security Group Structure

```hcl
resource "aws_security_group" "example" {
  name        = "security-group-name"
  description = "Security group description"
  vpc_id      = aws_vpc.main.id

  # Inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules (optional - defaults to allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-sg"
  }
}
```

### Key Terraform Resources

#### 1. aws_security_group
Main resource for creating security groups.

#### 2. aws_security_group_rule
Separate resource for individual rules (alternative approach).

```hcl
resource "aws_security_group_rule" "web_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}
```

#### 3. Data Sources for Default Resources

```hcl
# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Use in security group
resource "aws_security_group" "example" {
  vpc_id = data.aws_vpc.default.id
  # ... rest of configuration
}
```

## Challenge Implementation Analysis

### Challenge Requirements Breakdown

1. **Security Group Name**: `devops-sg`
2. **Description**: `Security group for Nautilus App Servers`
3. **VPC**: Default VPC (use data source)
4. **Inbound Rules**:
   - HTTP (port 80) from anywhere (0.0.0.0/0)
   - SSH (port 22) from anywhere (0.0.0.0/0)
5. **Region**: us-east-1
6. **File**: main.tf only

### What We're Building

```
Internet (0.0.0.0/0)
       │
       ▼
┌─────────────────┐
│   devops-sg     │
│                 │
│  ┌──────────┐   │
│  │HTTP (80) │◄──┼── Port 80 from anywhere
│  └──────────┘   │
│                 │
│  ┌──────────┐   │
│  │SSH (22)  │◄──┼── Port 22 from anywhere  
│  └──────────┘   │
│                 │
│  ┌──────────┐   │
│  │All Out   │───┼──► All outbound traffic allowed
│  └──────────┘   │
└─────────────────┘
       │
       ▼
   EC2 Instances
```

### Security Implications

#### Allowed Traffic Flows:
1. **HTTP (Port 80)**: Web traffic from anywhere
   - Use case: Public web servers
   - Risk: Publicly accessible web services

2. **SSH (Port 22)**: Remote access from anywhere
   - Use case: Administrative access
   - Risk: Brute force attacks, unauthorized access

3. **All Outbound**: Instances can connect to anywhere
   - Use case: Software updates, API calls
   - Risk: Data exfiltration, malware communication

### Implementation Code

```hcl
# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Create security group
resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Security group for Nautilus App Servers"
  vpc_id      = data.aws_vpc.default.id

  # HTTP inbound rule
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH inbound rule
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Default outbound rule (allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}
```

## Production vs Challenge Differences

### Challenge Implementation (Basic)

```hcl
# Simple, meets requirements
resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Security group for Nautilus App Servers"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}
```

### Production Implementation (Secure & Comprehensive)

#### 1. Restricted SSH Access
```hcl
# SSH only from office/VPN
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"  # Avoid naming conflicts
  description = "Web servers security group"
  vpc_id      = var.vpc_id

  # HTTP from load balancer only
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # SSH from bastion host only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Restricted outbound (only necessary traffic)
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP for package updates"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for package updates and APIs"
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-web-sg"
    Role = "web-server"
  })

  lifecycle {
    create_before_destroy = true
  }
}
```

#### 2. Multi-Tier Architecture
```hcl
# Load Balancer Security Group
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg-"
  description = "Application Load Balancer security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  name_prefix = "db-sg-"
  description = "Database security group"
  vpc_id      = var.vpc_id

  # MySQL from web servers only
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # No outbound rules (database doesn't need internet)
}
```

#### 3. Environment-Specific Configuration
```hcl
locals {
  # Different SSH access per environment
  ssh_allowed_cidrs = {
    dev     = ["0.0.0.0/0"]           # Open for development
    staging = ["10.0.0.0/8"]          # Internal network only
    prod    = ["203.0.113.0/24"]      # Office network only
  }
}

resource "aws_security_group" "app_sg" {
  name_prefix = "${var.environment}-app-sg-"
  description = "Application security group for ${var.environment}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.ssh_allowed_cidrs[var.environment]
    description = "SSH access for ${var.environment}"
  }
}
```

## Security Best Practices

### 1. Principle of Least Privilege

#### Bad Example (Overly Permissive)
```hcl
# DON'T DO THIS - Too open
resource "aws_security_group" "bad_example" {
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

#### Good Example (Minimal Access)
```hcl
# DO THIS - Only what's needed
resource "aws_security_group" "web_sg" {
  # Only HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access for web traffic"
  }

  # SSH from specific network only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]
    description = "SSH from office network"
  }
}
```

### 2. Use Security Group References

```hcl
# Instead of CIDR blocks, reference other security groups
resource "aws_security_group" "web_sg" {
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Not 0.0.0.0/0
    description     = "HTTP from load balancer"
  }
}
```

### 3. Implement Proper Tagging

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Owner       = var.team_email
    CostCenter  = var.cost_center
  }
}

resource "aws_security_group" "app_sg" {
  name_prefix = "${var.environment}-app-sg-"
  description = "Application security group"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.environment}-app-sg"
    Type = "application"
  })
}
```

### 4. Use Name Prefixes for Uniqueness

```hcl
# Use name_prefix instead of name to avoid conflicts
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"  # AWS will append unique suffix
  description = "Web server security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}
```

### 5. Restrict Outbound Traffic

```hcl
# Don't allow all outbound traffic
resource "aws_security_group" "secure_sg" {
  name_prefix = "secure-sg-"
  description = "Secure security group"
  vpc_id      = var.vpc_id

  # Explicit outbound rules
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP for package updates"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for secure communications"
  }

  # No default allow-all egress rule
}
```

## Real-World Implementation Patterns

### 1. Three-Tier Web Application

```hcl
# Internet-facing Load Balancer
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg-"
  description = "Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
}

# Web Tier
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"
  description = "Web servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.db_sg.id]
  }
}

# Database Tier
resource "aws_security_group" "db_sg" {
  name_prefix = "db-sg-"
  description = "Database servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # No outbound rules - database doesn't need internet
}
```

### 2. Microservices Architecture

```hcl
# Service mesh security groups with dynamic rules
resource "aws_security_group" "service_sg" {
  for_each = var.services

  name_prefix = "${each.key}-sg-"
  description = "Security group for ${each.key} service"
  vpc_id      = var.vpc_id

  # Allow traffic from other services
  dynamic "ingress" {
    for_each = each.value.allowed_services
    
    content {
      from_port       = each.value.port
      to_port         = each.value.port
      protocol        = "tcp"
      security_groups = [aws_security_group.service_sg[ingress.value].id]
      description     = "Access from ${ingress.value} service"
    }
  }

  tags = {
    Name    = "${each.key}-sg"
    Service = each.key
  }
}
```

### 3. Multi-Environment Security Groups

```hcl
# Security group module for different environments
module "security_groups" {
  source = "./modules/security-groups"

  for_each = {
    dev = {
      vpc_id            = module.vpc.dev_vpc_id
      ssh_allowed_cidrs = ["0.0.0.0/0"]
      environment       = "dev"
    }
    staging = {
      vpc_id            = module.vpc.staging_vpc_id
      ssh_allowed_cidrs = ["10.0.0.0/8"]
      environment       = "staging"
    }
    prod = {
      vpc_id            = module.vpc.prod_vpc_id
      ssh_allowed_cidrs = ["203.0.113.0/24"]
      environment       = "prod"
    }
  }

  vpc_id            = each.value.vpc_id
  ssh_allowed_cidrs = each.value.ssh_allowed_cidrs
  environment       = each.value.environment
}
```

## Troubleshooting and Monitoring

### Common Issues

#### 1. Connection Timeouts
**Symptoms**: Applications can't connect to services
**Causes**: 
- Missing inbound rules
- Wrong port numbers
- Incorrect CIDR blocks

**Debugging**:
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids sg-12345678

# Test connectivity
telnet <target-ip> <port>
nc -zv <target-ip> <port>
```

#### 2. Terraform Apply Failures
**Error**: `InvalidGroup.Duplicate`
```
Error: InvalidGroup.Duplicate: The security group 'devops-sg' already exists
```

**Solution**:
```hcl
# Use name_prefix instead
resource "aws_security_group" "devops_sg" {
  name_prefix = "devops-sg-"
  # ... rest of configuration
}
```

#### 3. VPC Not Found
**Error**: `InvalidVpcID.NotFound`
```
Error: InvalidVpcID.NotFound: The vpc ID 'vpc-12345' does not exist
```

**Solution**:
```hcl
# Use data source for default VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "example" {
  vpc_id = data.aws_vpc.default.id
}
```

### Security Group Monitoring

#### 1. VPC Flow Logs
```hcl
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "REJECT"  # Monitor rejected traffic
  vpc_id          = data.aws_vpc.default.id
}
```

#### 2. CloudWatch Metrics
```hcl
resource "aws_cloudwatch_metric_alarm" "high_rejected_traffic" {
  alarm_name          = "high-rejected-traffic"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "PacketsDroppedNoSecurityGroup"
  namespace           = "AWS/VPC"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "This metric monitors rejected traffic"
}
```

#### 3. Security Group Analysis
```bash
# List unused security groups
aws ec2 describe-security-groups --query 'SecurityGroups[?length(IpPermissions) == `0`]'

# Find overly permissive rules
aws ec2 describe-security-groups --query 'SecurityGroups[].IpPermissions[?contains(IpRanges[].CidrIp, `0.0.0.0/0`)]'
```

### Validation and Testing

```bash
# Validate Terraform configuration
terraform validate

# Plan to see what will be created
terraform plan

# Test security group rules after creation
aws ec2 describe-security-groups --group-ids sg-12345678

# Test actual connectivity
nmap -p 80,22 <target-ip>
```

This comprehensive guide provides everything needed to understand Security Groups, implement them securely with Terraform, and manage them in production environments. The next step is to create the actual implementation files for Challenge 95.