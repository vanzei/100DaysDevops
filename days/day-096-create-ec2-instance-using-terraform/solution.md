# Day 096: Create EC2 Instance Using Terraform - Complete Solution

## Challenge Overview

### Requirements
- **Instance Name**: `datacenter-ec2`
- **AMI**: `ami-0c101f26f147fa7fd` (Amazon Linux)
- **Instance Type**: `t2.micro`
- **Key Pair**: Create new RSA key named `datacenter-kp`
- **Security Group**: Attach default security group
- **Region**: us-east-1
- **File**: main.tf only
- **Directory**: /home/bob/terraform

## Step-by-Step Solution

### Step 1: Navigate to Working Directory

```bash
cd /home/bob/terraform
```

### Step 2: Create main.tf Configuration

Create the `main.tf` file with the complete EC2 instance configuration:

```hcl
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

# Generate RSA private key
resource "tls_private_key" "datacenter_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create RSA key pair for EC2 instance access
resource "aws_key_pair" "datacenter_kp" {
  key_name   = "datacenter-kp"
  public_key = tls_private_key.datacenter_key.public_key_openssh

  tags = {
    Name = "datacenter-kp"
  }
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
```

### Step 3: Initialize Terraform

Initialize the Terraform working directory:

```bash
terraform init
```

**Expected Output:**
```text
Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Finding latest version of hashicorp/tls...
- Installing hashicorp/aws v5.x.x...
- Installing hashicorp/tls v4.x.x...
- Installed hashicorp/aws v5.x.x (signed by HashiCorp)
- Installed hashicorp/tls v4.x.x (signed by HashiCorp)

Terraform has been successfully initialized!
```

### Step 4: Validate Configuration

Validate the Terraform configuration:

```bash
terraform validate
```

**Expected Output:**
```text
Success! The configuration is valid.
```

### Step 5: Plan the Deployment

Review what Terraform will create:

```bash
terraform plan
```

**Expected Output:**
```text
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.datacenter_ec2 will be created
  + resource "aws_instance" "datacenter_ec2" {
      + ami                                  = "ami-0c101f26f147fa7fd"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "datacenter-kp"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns_name                     = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "datacenter-ec2"
        }
      + tags_all                             = {
          + "Name" = "datacenter-ec2"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)
    }

  # aws_key_pair.datacenter_kp will be created
  + resource "aws_key_pair" "datacenter_kp" {
      + arn             = (known after apply)
      + fingerprint     = (known after apply)
      + id              = (known after apply)
      + key_name        = "datacenter-kp"
      + key_name_prefix = (known after apply)
      + key_pair_id     = (known after apply) 
      + key_type        = (known after apply)
      + public_key      = (known after apply)
      + tags            = {
          + "Name" = "datacenter-kp"
        }
      + tags_all        = {
          + "Name" = "datacenter-kp"
        }
    }

  # tls_private_key.datacenter_key will be created
  + resource "tls_private_key" "datacenter_key" {
      + algorithm                     = "RSA"
      + ecdsa_curve                   = "P224"
      + id                            = (known after apply)
      + private_key_openssh           = (sensitive value)
      + private_key_pem               = (sensitive value)
      + private_key_pem_pkcs8         = (sensitive value)
      + public_key_fingerprint_md5    = (known after apply)
      + public_key_fingerprint_sha256 = (known after apply)
      + public_key_openssh            = (known after apply)
      + public_key_pem                = (known after apply)
      + rsa_bits                      = 2048
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_id            = (known after apply)
  + instance_public_dns    = (known after apply)
  + instance_public_ip     = (known after apply)
  + private_key_pem        = (sensitive value)
  + ssh_connection_command = (known after apply)
```

### Step 6: Apply the Configuration

Create the resources:

```bash
terraform apply
```

When prompted, type `yes` to confirm:

```text
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

**Expected Output:**
```text
tls_private_key.datacenter_key: Creating...
tls_private_key.datacenter_key: Creation complete after 1s [id=...]
aws_key_pair.datacenter_kp: Creating...
aws_key_pair.datacenter_kp: Creation complete after 1s [id=datacenter-kp]
aws_instance.datacenter_ec2: Creating...
aws_instance.datacenter_ec2: Still creating... [10s elapsed]
aws_instance.datacenter_ec2: Still creating... [20s elapsed]
aws_instance.datacenter_ec2: Creation complete after 23s [id=i-0123456789abcdef0]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

instance_id = "i-0123456789abcdef0"
instance_public_dns = "ec2-198-51-100-1.compute-1.amazonaws.com"
instance_public_ip = "198.51.100.1"
private_key_pem = <sensitive>
ssh_connection_command = "ssh -i datacenter-kp.pem ec2-user@198.51.100.1"
```

### Step 7: Save Private Key for SSH Access

Extract and save the private key:

```bash
# Save private key to file
terraform output -raw private_key_pem > datacenter-kp.pem

# Set correct permissions
chmod 600 datacenter-kp.pem

# Verify permissions
ls -la datacenter-kp.pem
```

**Expected Output:**
```text
-rw------- 1 bob bob 1679 Nov  9 10:30 datacenter-kp.pem
```

### Step 8: Connect to EC2 Instance

Connect using SSH:

```bash
# Get connection command from output
terraform output ssh_connection_command

# Or connect directly
ssh -i datacenter-kp.pem ec2-user@$(terraform output -raw instance_public_ip)
```

**Expected SSH Connection:**
```text
The authenticity of host '198.51.100.1 (198.51.100.1)' can't be established.
ED25519 key fingerprint is SHA256:...
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '198.51.100.1' (ED25519) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
[ec2-user@ip-172-31-x-x ~]$
```

## Configuration Deep Dive

### Resource Analysis

#### 1. Data Sources (Query Existing Resources)

##### Default VPC Discovery
```hcl
data "aws_vpc" "default" {
  default = true
}
```

**Purpose:**
- Finds the default VPC in the current region
- Required for security group lookup
- Provides VPC ID for other resources

**Why This Matters:**
- Every AWS account has a default VPC
- Security groups are VPC-specific
- Ensures resources are created in correct network

##### Default Security Group Discovery
```hcl
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}
```

**Purpose:**
- Locates the default security group
- Provides security group ID for EC2 instance
- Uses VPC ID from previous data source

**Default Security Group Rules:**
- **Inbound**: Allow all traffic from same security group
- **Outbound**: Allow all traffic to anywhere
- **Effect**: Instances can communicate with each other, access internet

#### 2. TLS Private Key Generation

##### RSA Key Generation
```hcl
resource "tls_private_key" "datacenter_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
```

**RSA Parameters Explained:**

| Parameter | Value | Significance |
|-----------|-------|--------------|
| **algorithm** | RSA | Public-key cryptography standard |
| **rsa_bits** | 2048 | Key length (security vs performance) |
| **Generated** | Private Key | Never transmitted, stays secure |
| **Generated** | Public Key | Shared with AWS, stored on instance |

**Security Analysis:**
- **2048-bit RSA**: Current security standard
- **Private Key**: Contains both private and public key components
- **Public Key**: Derived from private key mathematically
- **Entropy**: Generated using cryptographically secure random numbers

#### 3. AWS Key Pair Creation

##### Key Pair Resource
```hcl
resource "aws_key_pair" "datacenter_kp" {
  key_name   = "datacenter-kp"
  public_key = tls_private_key.datacenter_key.public_key_openssh
}
```

**AWS Key Pair Service:**
- **Stores**: Public key only in AWS
- **Returns**: Key pair metadata and fingerprint
- **Usage**: Injects public key into EC2 instances
- **Security**: Private key never sent to AWS

**Key Formats:**
```bash
# OpenSSH format (used by AWS)
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ... 

# PEM format (traditional)
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCg...
-----END PUBLIC KEY-----
```

#### 4. EC2 Instance Configuration

##### Instance Resource
```hcl
resource "aws_instance" "datacenter_ec2" {
  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.datacenter_kp.key_name
  vpc_security_group_ids = [data.aws_security_group.default.id]
}
```

**Configuration Breakdown:**

| Attribute | Value | Purpose |
|-----------|-------|---------|
| **ami** | ami-0c101f26f147fa7fd | Amazon Linux 2 image |
| **instance_type** | t2.micro | Burstable performance, free tier |
| **key_name** | datacenter-kp | SSH access key pair |
| **vpc_security_group_ids** | [default-sg-id] | Network security rules |

### Security Architecture

#### Authentication Flow

##### 1. Key Pair Creation Process
```text
Terraform Execution:
1. Generate RSA private/public key pair locally
2. Send public key to AWS Key Pair service
3. AWS stores public key with name "datacenter-kp"
4. AWS returns key pair metadata (fingerprint, ID)
```

##### 2. Instance Launch Process
```text
EC2 Instance Launch:
1. AWS retrieves public key for "datacenter-kp"
2. Injects public key into instance metadata
3. cloud-init configures SSH authorized_keys
4. Instance boots with SSH daemon enabled
```

##### 3. SSH Authentication Process
```text
SSH Connection:
1. Client presents private key for authentication
2. Server challenges client with random data
3. Client signs challenge with private key
4. Server verifies signature with stored public key
5. Connection established if verification succeeds
```

#### Network Security Model

##### Security Group Rules (Default)
```text
Inbound Rules:
┌─────────────┬──────────┬───────────┬─────────────────┬─────────────────────┐
│    Type     │ Protocol │   Port    │     Source      │    Description      │
├─────────────┼──────────┼───────────┼─────────────────┼─────────────────────┤
│ All Traffic │   All    │    All    │ sg-xxxxx (self) │ Default group rule  │
└─────────────┴──────────┴───────────┴─────────────────┴─────────────────────┘

Outbound Rules:
┌─────────────┬──────────┬───────────┬─────────────────┬─────────────────────┐
│    Type     │ Protocol │   Port    │  Destination    │    Description      │
├─────────────┼──────────┼───────────┼─────────────────┼─────────────────────┤
│ All Traffic │   All    │    All    │   0.0.0.0/0     │ All outbound        │
└─────────────┴──────────┴───────────┴─────────────────┴─────────────────────┘
```

##### Access Implications
```text
✅ Allowed Connections:
├── Instance to Internet (outbound)
├── Instance to other instances (same security group)
├── Other instances to this instance (same security group)
└── AWS services (S3, CloudWatch, etc.)

❌ Blocked Connections:
├── Internet to instance (inbound)
├── SSH from external networks
├── HTTP/HTTPS from internet
└── Other security groups to instance
```

## Validation and Testing

### 1. Terraform State Verification

#### Check Created Resources
```bash
# List all resources in state
terraform state list

# Show specific resource details
terraform state show aws_instance.datacenter_ec2
terraform state show aws_key_pair.datacenter_kp
terraform state show tls_private_key.datacenter_key
```

#### Verify Outputs
```bash
# View all outputs
terraform output

# Get specific values
terraform output instance_id
terraform output instance_public_ip
terraform output -raw ssh_connection_command
```

### 2. AWS Console Verification

#### EC2 Dashboard Checks
1. **Instances**: Verify "datacenter-ec2" is running
2. **Key Pairs**: Confirm "datacenter-kp" exists
3. **Security Groups**: Check default security group attachment
4. **VPC**: Verify instance is in default VPC

#### Instance Details Verification
```bash
# AWS CLI verification
aws ec2 describe-instances --instance-ids $(terraform output -raw instance_id)

# Check key pair
aws ec2 describe-key-pairs --key-names datacenter-kp

# Verify security groups
aws ec2 describe-security-groups --group-ids $(terraform output -raw security_group_id)
```

### 3. Connectivity Testing

#### SSH Connection Test
```bash
# Test SSH connectivity
ssh -i datacenter-kp.pem -o ConnectTimeout=10 ec2-user@$(terraform output -raw instance_public_ip) "echo 'Connection successful'"
```

#### Instance System Information
```bash
# After connecting via SSH, check system details
uname -a                    # Kernel information
cat /etc/os-release        # OS version
df -h                      # Disk usage
free -m                    # Memory usage
lscpu                      # CPU information
```

#### Network Configuration Check
```bash
# Check network configuration
ip addr show               # Network interfaces
ip route show              # Routing table
cat /etc/resolv.conf      # DNS configuration
curl -s http://169.254.169.254/latest/meta-data/instance-id  # Instance metadata
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Authentication Failures

##### Issue: Permission denied (publickey)
```text
Permission denied (publickey).
```

**Diagnosis:**
```bash
# Check private key permissions
ls -la datacenter-kp.pem

# Check SSH configuration
ssh -v -i datacenter-kp.pem ec2-user@<instance-ip>
```

**Solutions:**
```bash
# Fix key permissions
chmod 600 datacenter-kp.pem
chown $USER:$USER datacenter-kp.pem

# Regenerate key if corrupted
terraform output -raw private_key_pem > datacenter-kp.pem
chmod 600 datacenter-kp.pem

# Verify key format
file datacenter-kp.pem  # Should show "PEM RSA private key"
```

#### 2. Network Connectivity Issues

##### Issue: Connection timeout
```text
ssh: connect to host x.x.x.x port 22: Connection timed out
```

**Diagnosis:**
```bash
# Check instance state
aws ec2 describe-instances --instance-ids $(terraform output -raw instance_id) \
  --query 'Reservations[0].Instances[0].State'

# Check security group rules
aws ec2 describe-security-groups --group-ids <security-group-id>

# Test network connectivity
telnet <instance-ip> 22
```

**Solutions:**
```bash
# Add SSH rule to security group (if needed for external access)
aws ec2 authorize-security-group-ingress \
  --group-id <security-group-id> \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# Check instance is running
aws ec2 start-instances --instance-ids $(terraform output -raw instance_id)
```

#### 3. Terraform State Issues

##### Issue: Resource already exists
```text
Error: InvalidKeyPair.Duplicate: The key pair 'datacenter-kp' already exists
```

**Solutions:**
```bash
# Option 1: Import existing resource
terraform import aws_key_pair.datacenter_kp datacenter-kp

# Option 2: Delete existing key pair
aws ec2 delete-key-pair --key-name datacenter-kp
terraform apply

# Option 3: Use different key name
# Modify main.tf to use unique name
```

##### Issue: State file corruption
```text
Error: Failed to load state: state snapshot was created by Terraform vX.X.X
```

**Solutions:**
```bash
# Backup state file
cp terraform.tfstate terraform.tfstate.backup

# Upgrade state file format
terraform state replace-provider -auto-approve

# If all else fails, recreate from scratch
rm terraform.tfstate*
terraform import aws_key_pair.datacenter_kp datacenter-kp
terraform import aws_instance.datacenter_ec2 i-xxxxxxxxx
```

#### 4. Provider Configuration Issues

##### Issue: No credential sources found
```text
Error: No valid credential sources found for AWS Provider
```

**Solutions:**
```bash
# Configure AWS credentials
aws configure
# Or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Verify credentials
aws sts get-caller-identity
```

### Advanced SSH Configuration

#### 1. SSH Config File Setup
```bash
# Create SSH config for easier access
cat >> ~/.ssh/config << EOF
Host datacenter-ec2
    HostName $(terraform output -raw instance_public_ip)
    User ec2-user
    IdentityFile ./datacenter-kp.pem
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF

# Connect using hostname
ssh datacenter-ec2
```

#### 2. SSH Agent Integration
```bash
# Add key to SSH agent
ssh-add datacenter-kp.pem

# Verify key is loaded
ssh-add -l

# Connect without specifying key
ssh ec2-user@$(terraform output -raw instance_public_ip)
```

#### 3. SSH Tunneling (for services)
```bash
# Forward local port 8080 to instance port 80
ssh -L 8080:localhost:80 \
    -i datacenter-kp.pem \
    ec2-user@$(terraform output -raw instance_public_ip)

# Access via http://localhost:8080
```

## Production Enhancements

### 1. Enhanced Security Configuration

#### Restricted Security Group
```hcl
# Create custom security group with specific access
resource "aws_security_group" "datacenter_secure" {
  name_prefix = "datacenter-secure-"
  description = "Secure access for datacenter EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  # SSH access from specific IP range
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]  # Replace with your office network
    description = "SSH from office network"
  }

  # Outbound HTTPS for package updates
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound"
  }

  # Outbound HTTP for package repositories
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP outbound"
  }

  tags = {
    Name = "datacenter-secure-sg"
  }
}
```

#### IAM Role Integration
```hcl
# IAM role for EC2 instance
resource "aws_iam_role" "datacenter_role" {
  name = "datacenter-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies for CloudWatch logging
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.datacenter_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance profile
resource "aws_iam_instance_profile" "datacenter_profile" {
  name = "datacenter-profile"
  role = aws_iam_role.datacenter_role.name
}
```

### 2. Monitoring and Logging

#### CloudWatch Integration
```hcl
# CloudWatch log group
resource "aws_cloudwatch_log_group" "datacenter_logs" {
  name              = "/aws/ec2/datacenter"
  retention_in_days = 30

  tags = {
    Name = "datacenter-logs"
  }
}

# CloudWatch alarm for high CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "datacenter-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors ec2 cpu utilization"

  dimensions = {
    InstanceId = aws_instance.datacenter_ec2.id
  }

  alarm_actions = [aws_sns_topic.datacenter_alerts.arn]
}
```

### 3. Backup and Recovery

#### EBS Volume and Snapshots
```hcl
# Additional EBS volume for data
resource "aws_ebs_volume" "datacenter_data" {
  availability_zone = aws_instance.datacenter_ec2.availability_zone
  size              = 20
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "datacenter-data-volume"
  }
}

# Attach volume
resource "aws_volume_attachment" "datacenter_data_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.datacenter_data.id
  instance_id = aws_instance.datacenter_ec2.id
}

# Scheduled snapshots
resource "aws_ebs_snapshot" "datacenter_snapshot" {
  volume_id   = aws_ebs_volume.datacenter_data.id
  description = "Daily snapshot of datacenter data volume"

  tags = {
    Name = "datacenter-daily-snapshot"
  }
}
```

## Cleanup Instructions

### Step 1: Terminate Resources

```bash
# Destroy all resources
terraform destroy
```

When prompted, type `yes` to confirm:

```text
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

**Expected Output:**
```text
aws_instance.datacenter_ec2: Destroying... [id=i-0123456789abcdef0]
aws_instance.datacenter_ec2: Still destroying... [id=i-0123456789abcdef0, 10s elapsed]
aws_instance.datacenter_ec2: Still destroying... [id=i-0123456789abcdef0, 20s elapsed]
aws_instance.datacenter_ec2: Destruction complete after 21s
aws_key_pair.datacenter_kp: Destroying... [id=datacenter-kp]
aws_key_pair.datacenter_kp: Destruction complete after 1s
tls_private_key.datacenter_key: Destroying... [id=...]
tls_private_key.datacenter_key: Destruction complete after 0s

Destroy complete! Resources: 3 destroyed.
```

### Step 2: Clean Up Local Files

```bash
# Remove private key file
rm -f datacenter-kp.pem

# Remove Terraform state files (if desired)
rm -f terraform.tfstate*

# Remove .terraform directory (if desired)
rm -rf .terraform/
```

## Key Learning Points

### 1. Infrastructure as Code Benefits
- **Reproducible**: Same configuration creates identical infrastructure
- **Version Controlled**: Track changes and collaborate effectively
- **Automated**: Reduce manual errors and deployment time
- **Scalable**: Easy to create multiple similar environments

### 2. RSA Cryptography in Practice
- **Mathematical Security**: Based on prime factorization difficulty
- **Key Pair Relationship**: Public key derived from private key
- **SSH Authentication**: Challenge-response without password transmission
- **Terraform Integration**: Automated key generation and management

### 3. AWS EC2 Fundamentals
- **Instance Types**: Right-sizing for workload requirements
- **AMI Selection**: Operating system and pre-installed software choices
- **Security Groups**: Instance-level firewall configuration
- **Key Pairs**: Secure authentication mechanism

### 4. Security Best Practices
- **Least Privilege**: Minimal required permissions and access
- **Defense in Depth**: Multiple security layers (network, instance, application)
- **Key Management**: Secure generation, storage, and rotation
- **Monitoring**: Logging and alerting for security events

This comprehensive solution provides both the minimal configuration required for Challenge 96 and advanced knowledge for implementing secure, production-ready EC2 instances in real-world scenarios.