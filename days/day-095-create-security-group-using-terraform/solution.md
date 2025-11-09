# Day 095: Create Security Group Using Terraform - Complete Solution

## Challenge Overview

### Requirements
- **Security Group Name**: `devops-sg`
- **Description**: `Security group for Nautilus App Servers`
- **VPC**: Default VPC
- **Inbound Rules**:
  - HTTP (port 80) from anywhere (0.0.0.0/0)
  - SSH (port 22) from anywhere (0.0.0.0/0)
- **Region**: us-east-1
- **File**: main.tf only
- **Directory**: /home/bob/terraform

## Step-by-Step Solution

### Step 1: Navigate to Working Directory

```bash
cd /home/bob/terraform
```

### Step 2: Create main.tf Configuration

Create the `main.tf` file with the Security Group configuration:

```hcl
# Day 095: Create Security Group Using Terraform
# Path: /home/bob/terraform/main.tf

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Create security group named devops-sg
resource "aws_security_group" "xfusion-sg" {
  name        = "xfusion-sg"
  description = "Security group for Nautilus App Servers"
  vpc_id      = data.aws_vpc.default.id

  # HTTP inbound rule - allow traffic on port 80 from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from anywhere"
  }

  # SSH inbound rule - allow traffic on port 22 from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access from anywhere"
  }

  # Default outbound rule - allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "xfusion-sg"
  }
}
```

### Step 3: Initialize Terraform

Initialize the Terraform working directory:

```bash
terraform init
```

**Expected Output:**
```
Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v5.x.x...
- Installed hashicorp/aws v5.x.x (signed by HashiCorp)

Terraform has been successfully initialized!
```

### Step 4: Validate Configuration

Validate the Terraform configuration:

```bash
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

### Step 5: Plan the Deployment

Review what Terraform will create:

```bash
terraform plan
```

**Expected Output:**
```
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_security_group.devops_sg will be created
  + resource "aws_security_group" "devops_sg" {
      + arn                    = (known after apply)
      + description            = "Security group for Nautilus App Servers"
      + egress                 = [
          + {
              + cidr_blocks      = ["0.0.0.0/0"]
              + description      = "All outbound traffic"
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = ["0.0.0.0/0"]
              + description      = "HTTP access from anywhere"
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = ["0.0.0.0/0"]
              + description      = "SSH access from anywhere"
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "devops-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "devops-sg"
        }
      + tags_all               = {
          + "Name" = "devops-sg"
        }
      + vpc_id                 = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

### Step 6: Apply the Configuration

Create the Security Group:

```bash
terraform apply
```

When prompted, type `yes` to confirm:

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

**Expected Output:**
```
aws_security_group.devops_sg: Creating...
aws_security_group.devops_sg: Creation complete after 2s [id=sg-xxxxxxxxxxxxxxxxx]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

### Step 7: Verify the Security Group

Check the created Security Group:

```bash
terraform show
```

Or verify using AWS CLI:

```bash
aws ec2 describe-security-groups --group-names devops-sg --region us-east-1
```

## Configuration Explanation

### Data Source Block
```hcl
data "aws_vpc" "default" {
  default = true
}
```
- **Purpose**: Retrieves information about the default VPC
- **Usage**: Provides VPC ID for the security group
- **Benefit**: Automatically finds default VPC without hardcoding IDs

### Security Group Resource Block
```hcl
resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Security group for Nautilus App Servers"
  vpc_id      = data.aws_vpc.default.id
  # ... rules and tags
}
```

#### Key Attributes Explained:

##### 1. Basic Configuration
- **`name`**: Unique identifier for the security group within the VPC
- **`description`**: Human-readable description of the security group's purpose
- **`vpc_id`**: References the default VPC using data source

##### 2. Ingress Rules (Inbound Traffic)

**HTTP Rule:**
```hcl
ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "HTTP access from anywhere"
}
```
- **Port**: 80 (HTTP standard port)
- **Protocol**: TCP (required for HTTP)
- **Source**: 0.0.0.0/0 (anywhere on the internet)
- **Use Case**: Web servers serving HTTP content

**SSH Rule:**
```hcl
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "SSH access from anywhere"
}
```
- **Port**: 22 (SSH standard port)
- **Protocol**: TCP (required for SSH)
- **Source**: 0.0.0.0/0 (anywhere on the internet)
- **Use Case**: Remote administrative access

##### 3. Egress Rules (Outbound Traffic)
```hcl
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "All outbound traffic"
}
```
- **Port Range**: 0-0 (all ports)
- **Protocol**: -1 (all protocols)
- **Destination**: 0.0.0.0/0 (anywhere)
- **Purpose**: Allows instances to make outbound connections

## Security Analysis

### What This Configuration Allows

#### Inbound Traffic Flow
```
Internet (Any IP) → HTTP (Port 80) → EC2 Instances
Internet (Any IP) → SSH (Port 22)  → EC2 Instances
```

#### Outbound Traffic Flow
```
EC2 Instances → Any Protocol → Any Destination → Internet
```

### Security Implications

#### Positive Aspects
1. **Specific Ports**: Only opens necessary ports (22, 80)
2. **Clear Documentation**: Each rule has descriptive comments
3. **Stateful**: Response traffic automatically allowed

#### Security Concerns (Production Considerations)
1. **SSH from Anywhere**: 0.0.0.0/0 for SSH is a security risk
2. **No Logging**: No traffic monitoring or logging configured
3. **All Outbound**: Unrestricted egress traffic

### Risk Assessment Matrix

| Rule | Risk Level | Justification | Mitigation |
|------|------------|---------------|------------|
| HTTP (0.0.0.0/0) | Medium | Public web access needed | Use ALB, implement WAF |
| SSH (0.0.0.0/0) | High | Admin access from anywhere | Restrict to office IPs |
| All Outbound | Medium | Unrestricted internet access | Whitelist specific destinations |

## Expected Results

### Successful Terraform Apply Output
```
data.aws_vpc.default: Reading...
data.aws_vpc.default: Read complete after 1s [id=vpc-12345678]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_security_group.devops_sg will be created
  + resource "aws_security_group" "devops_sg" {
      + arn                    = (known after apply)
      + description            = "Security group for Nautilus App Servers"
      + egress                 = [...]
      + id                     = (known after apply)
      + ingress                = [...]
      + name                   = "devops-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "devops-sg"
        }
      + tags_all               = {
          + "Name" = "devops-sg"
        }
      + vpc_id                 = "vpc-12345678"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_security_group.devops_sg: Creating...
aws_security_group.devops_sg: Creation complete after 2s [id=sg-0123456789abcdef0]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

### Security Group Properties (terraform show)
```hcl
# aws_security_group.devops_sg:
resource "aws_security_group" "devops_sg" {
    arn                    = "arn:aws:ec2:us-east-1:123456789012:security-group/sg-0123456789abcdef0"
    description            = "Security group for Nautilus App Servers"
    egress                 = [
        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = "All outbound traffic"
            from_port        = 0
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "-1"
            security_groups  = []
            self             = false
            to_port          = 0
        },
    ]
    id                     = "sg-0123456789abcdef0"
    ingress                = [
        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = "HTTP access from anywhere"
            from_port        = 80
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "tcp"
            security_groups  = []
            self             = false
            to_port          = 80
        },
        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = "SSH access from anywhere"
            from_port        = 22
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "tcp"
            security_groups  = []
            self             = false
            to_port          = 22
        },
    ]
    name                   = "devops-sg"
    name_prefix            = ""
    owner_id               = "123456789012"
    revoke_rules_on_delete = false
    tags                   = {
        "Name" = "devops-sg"
    }
    tags_all               = {
        "Name" = "devops-sg"
    }
    vpc_id                 = "vpc-12345678"
}
```

## Validation Steps

### 1. Terraform Validation
```bash
# Check Terraform state
terraform state list

# Show security group details
terraform state show aws_security_group.devops_sg

# Validate configuration
terraform validate

# Check for drift
terraform plan
```

### 2. AWS CLI Verification
```bash
# List security groups
aws ec2 describe-security-groups --region us-east-1

# Get specific security group
aws ec2 describe-security-groups --group-names devops-sg --region us-east-1

# Get security group by ID
aws ec2 describe-security-groups --group-ids sg-0123456789abcdef0 --region us-east-1

# Check rules specifically
aws ec2 describe-security-groups --group-names devops-sg --query 'SecurityGroups[0].IpPermissions' --region us-east-1
```

### 3. AWS Console Verification
1. Navigate to EC2 Dashboard → Security Groups
2. Find "devops-sg" in the list
3. Verify Inbound Rules:
   - HTTP (80) from 0.0.0.0/0
   - SSH (22) from 0.0.0.0/0
4. Verify Outbound Rules:
   - All traffic to 0.0.0.0/0

### 4. Network Testing (After Attaching to Instance)
```bash
# Test HTTP connectivity
curl -I http://<instance-ip>

# Test SSH connectivity
ssh -o ConnectTimeout=5 ec2-user@<instance-ip>

# Port scanning (from external machine)
nmap -p 22,80 <instance-ip>
```

## Troubleshooting Guide

### Common Issues

#### 1. Security Group Name Already Exists
**Error:**
```
Error: InvalidGroup.Duplicate: The security group 'devops-sg' already exists for VPC 'vpc-12345678'
```

**Solutions:**
```bash
# Option 1: Delete existing security group
aws ec2 delete-security-group --group-name devops-sg

# Option 2: Import existing security group
terraform import aws_security_group.devops_sg sg-existing123

# Option 3: Use name_prefix instead of name
# In main.tf, change:
name = "devops-sg"
# To:
name_prefix = "devops-sg-"
```

#### 2. Default VPC Not Found
**Error:**
```
Error: Your query returned no results. Please change your search criteria and try again.
```

**Solution:**
```hcl
# Check if default VPC exists
data "aws_vpcs" "available" {
  tags = {
    Name = "default"
  }
}

# Or specify VPC ID directly
resource "aws_security_group" "devops_sg" {
  vpc_id = "vpc-12345678"  # Replace with actual VPC ID
  # ... rest of configuration
}
```

#### 3. Provider Authentication Issues
**Error:**
```
Error: No valid credential sources found for AWS Provider
```

**Solution:**
```bash
# Check AWS configuration
aws configure list

# Verify credentials
aws sts get-caller-identity

# Set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

#### 4. Permission Denied Errors
**Error:**
```
Error: UnauthorizedOperation: You are not authorized to perform this operation
```

**Solution:**
- Verify IAM permissions include:
  - `ec2:CreateSecurityGroup`
  - `ec2:DescribeSecurityGroups`
  - `ec2:AuthorizeSecurityGroupIngress`
  - `ec2:AuthorizeSecurityGroupEgress`
  - `ec2:DescribeVpcs`

### Debugging Commands

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH="./terraform.log"

# Check Terraform version
terraform version

# Validate syntax
terraform validate

# Format code
terraform fmt

# Show current state
terraform show

# Refresh state
terraform refresh
```

## Production Enhancements

### 1. Secure SSH Configuration
```hcl
# Replace open SSH with restricted access
resource "aws_security_group" "devops_sg_secure" {
  name        = "devops-sg"
  description = "Security group for Nautilus App Servers"
  vpc_id      = data.aws_vpc.default.id

  # HTTP - same as challenge
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from anywhere"
  }

  # SSH - restricted to office network
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]  # Office network
    description = "SSH access from office"
  }

  # Restricted outbound
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

  tags = {
    Name        = "devops-sg"
    Environment = "production"
    Security    = "enhanced"
  }
}
```

### 2. Load Balancer Integration
```hcl
# Security group for Application Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

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
    security_groups = [aws_security_group.devops_sg.id]
  }
}

# Modified web server security group
resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Security group for Nautilus App Servers"
  vpc_id      = data.aws_vpc.default.id

  # HTTP only from load balancer
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "HTTP from load balancer"
  }

  # SSH from bastion host only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
    description     = "SSH from bastion host"
  }
}
```

## Cleanup (Optional)

To remove the created Security Group:

```bash
terraform destroy
```

When prompted, type `yes` to confirm:

```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_security_group.devops_sg: Destroying... [id=sg-0123456789abcdef0]
aws_security_group.devops_sg: Destruction complete after 1s

Destroy complete! Resources: 1 destroyed.
```

## Key Learning Points

### 1. Security Group Fundamentals
- **Stateful Firewall**: Automatically handles response traffic
- **Allow Rules Only**: Cannot create explicit deny rules
- **Instance-Level**: Applied to network interfaces, not subnets

### 2. Terraform Best Practices
- **Data Sources**: Use for existing resources (like default VPC)
- **Descriptive Comments**: Document the purpose of each rule
- **Proper Tagging**: Include Name tags for resource identification

### 3. Security Considerations
- **0.0.0.0/0 Risks**: Opening ports to the entire internet increases attack surface
- **SSH Security**: Consider bastion hosts or VPN for administrative access
- **Least Privilege**: Only open ports that are absolutely necessary

### 4. Production Readiness
- **Multi-Layer Security**: Combine with Network ACLs, WAF, and host-based firewalls
- **Monitoring**: Implement VPC Flow Logs and CloudWatch alerts
- **Regular Audits**: Review and update security group rules regularly

This comprehensive solution provides both the minimal configuration required for Challenge 95 and the knowledge needed to implement secure, production-ready Security Groups in real-world scenarios.