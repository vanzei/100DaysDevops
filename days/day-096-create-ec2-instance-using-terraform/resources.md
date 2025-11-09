# Day 096: Create EC2 Instance Using Terraform - Resources & Documentation

## Table of Contents
1. [Challenge Overview](#challenge-overview)
2. [EC2 Instance Fundamentals](#ec2-instance-fundamentals)
3. [RSA Cryptography Deep Dive](#rsa-cryptography-deep-dive)
4. [Key Pair Authentication](#key-pair-authentication)
5. [Amazon Machine Images (AMI)](#amazon-machine-images-ami)
6. [Instance Types and Sizing](#instance-types-and-sizing)
7. [Security Groups and Network Security](#security-groups-and-network-security)
8. [Terraform Resource Configuration](#terraform-resource-configuration)
9. [Security Best Practices](#security-best-practices)
10. [Production Considerations](#production-considerations)

## Challenge Overview

### What We're Building
This challenge involves creating a complete EC2 instance deployment using Terraform, including:
- **RSA Key Pair Generation**: For secure SSH access
- **EC2 Instance Creation**: Virtual server in AWS cloud
- **Security Group Attachment**: Network-level firewall rules
- **Output Configuration**: For easy access and management

### Why This Matters
EC2 instances are the foundation of AWS compute services. Understanding how to provision them securely with proper authentication is crucial for:
- **Infrastructure as Code**: Reproducible, version-controlled deployments
- **Security**: Proper key management and access control
- **Scalability**: Foundation for auto-scaling and load balancing
- **Cost Management**: Right-sizing instances for workloads

## EC2 Instance Fundamentals

### What is Amazon EC2?

**Amazon Elastic Compute Cloud (EC2)** is a web service that provides secure, resizable compute capacity in the cloud. It's designed to make web-scale cloud computing easier for developers.

#### Core Concepts

##### 1. Virtual Servers in the Cloud
```
Traditional Server:
Physical Hardware → Operating System → Applications

EC2 Instance:
AWS Hardware → Hypervisor → Virtual Machine → Operating System → Applications
```

##### 2. Instance Lifecycle States
```
Pending → Running → Stopping → Stopped → Terminating → Terminated
    ↓         ↑         ↓         ↑
   Launch   Reboot    Stop     Start
```

##### 3. Instance Components
- **Compute**: CPU, Memory, Network performance
- **Storage**: EBS volumes, Instance store
- **Networking**: VPC, Security groups, Elastic IPs
- **Security**: Key pairs, IAM roles, Security groups

### Why EC2 for This Challenge?

#### Infrastructure Migration Benefits
1. **Scalability**: Start small (t2.micro), scale as needed
2. **Cost-Effective**: Pay only for what you use
3. **Reliability**: AWS global infrastructure
4. **Flexibility**: Multiple OS options and configurations

#### Learning Value
- Foundation for all AWS compute services
- Understanding of cloud server management
- Base for container services (ECS, EKS)
- Integration point for other AWS services

## RSA Cryptography Deep Dive

### What is RSA?

**RSA (Rivest-Shamir-Adleman)** is a public-key cryptography algorithm used for secure data transmission and authentication.

#### Mathematical Foundation

##### The RSA Algorithm
```
1. Key Generation:
   - Choose two large prime numbers: p and q
   - Compute n = p × q (modulus)
   - Compute φ(n) = (p-1)(q-1) (Euler's totient)
   - Choose public exponent e (commonly 65537)
   - Compute private exponent d where (d × e) ≡ 1 (mod φ(n))

2. Public Key: (n, e)
3. Private Key: (n, d)
```

##### Why 2048 bits?
```
Key Size vs Security:
1024 bits: Deprecated (can be broken)
2048 bits: Current standard (secure until ~2030)
3072 bits: Extended security
4096 bits: Maximum security (slower performance)
```

### RSA in SSH Authentication

#### How SSH Key Authentication Works

##### Traditional Password Authentication Flow:
```
Client                           Server
  |                               |
  |---- Username/Password ------> |
  |                               | (Verify password)
  |<------- Access Granted ------ |
```

##### RSA Key Authentication Flow:
```
Client                           Server
  |                               |
  |---- Public Key ID ----------> |
  |                               | (Find matching public key)
  |<------ Random Challenge ----- |
  | (Sign challenge with          |
  |  private key)                |
  |---- Signed Challenge -------> |
  |                               | (Verify signature with public key)
  |<------- Access Granted ------ |
```

#### Why RSA Keys Are Superior to Passwords

##### 1. **Mathematical Security**
```
Password Security:
- Based on human memory
- Often predictable patterns
- Vulnerable to brute force
- Shared across systems

RSA Key Security:
- 2048-bit key = 2^2048 possible combinations
- Mathematically infeasible to brute force
- Unique per system/user
- Never transmitted over network
```

##### 2. **Practical Security Benefits**

| Aspect | Password | RSA Keys |
|--------|----------|----------|
| **Strength** | Weak (human-memorable) | Strong (cryptographically random) |
| **Transmission** | Sent over network | Never transmitted |
| **Storage** | Plain text or hashed | Public key only on server |
| **Automation** | Requires human input | Fully automated |
| **Revocation** | Change on all systems | Remove public key |

##### 3. **Attack Resistance**

**Password Vulnerabilities:**
- **Brute Force**: Systematic guessing
- **Dictionary Attacks**: Common password lists
- **Social Engineering**: Human manipulation
- **Keyloggers**: Capture keystrokes
- **Network Sniffing**: Intercept transmission

**RSA Key Advantages:**
- **No Network Transmission**: Private key never leaves client
- **Challenge-Response**: Different every time
- **Mathematical Hardness**: Based on prime factorization
- **No Human Memory**: Can't be socially engineered

### RSA Key Components Explained

#### Public Key Structure
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... user@hostname
   ↑         ↑                      ↑           ↑
   |         |                      |           └── Comment (optional)
   |         |                      └────────────── Key material (base64)
   |         └─────────────────────────────────── Algorithm identifier
   └───────────────────────────────────────────── Key type
```

#### Private Key Structure (PEM Format)
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAy8Dbv8prpH/6+P2bxGK...  ← Private key material
                                            (base64 encoded)
-----END RSA PRIVATE KEY-----
```

### Why We Generate Keys in Terraform

#### 1. **Infrastructure as Code Benefits**
```hcl
# Declarative key generation
resource "tls_private_key" "datacenter_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
```

**Advantages:**
- **Reproducible**: Same configuration, same result
- **Version Controlled**: Track key generation in Git
- **Automated**: No manual key generation steps
- **Integrated**: Keys created alongside infrastructure

#### 2. **Security Considerations**

**Terraform State Security:**
```hcl
# Mark sensitive outputs
output "private_key_pem" {
  value     = tls_private_key.datacenter_key.private_key_pem
  sensitive = true  # Prevents accidental exposure in logs
}
```

**Best Practices:**
- Use remote state with encryption
- Restrict state file access
- Consider external key management for production

#### 3. **Key Lifecycle Management**

**Terraform Managed:**
```
Create → Store in State → Use in Resources → Destroy with Infrastructure
```

**Benefits:**
- Automatic cleanup
- Consistent with infrastructure lifecycle
- Easy to recreate environments

## Key Pair Authentication

### AWS Key Pair Service

#### What AWS Does
```
Your Request:           AWS Action:              Result:
Public Key    ────────> Store in Key Service ───> EC2 Metadata
    ↓                                              ↓
Private Key   ────────> Return to You ─────────> SSH Client
```

#### EC2 Key Pair Injection Process

##### Instance Launch Process:
```
1. Launch Instance with Key Pair Name
2. AWS injects public key into: ~/.ssh/authorized_keys
3. Instance boots with SSH daemon configured
4. You connect using corresponding private key
```

##### User Data Script (Automatic):
```bash
#!/bin/bash
# AWS automatically runs equivalent of:
echo "ssh-rsa AAAAB3NzaC1yc2E... datacenter-kp" >> /home/ec2-user/.ssh/authorized_keys
chmod 600 /home/ec2-user/.ssh/authorized_keys
chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
```

### SSH Connection Process

#### Complete Authentication Flow

##### 1. **SSH Client Initiation**
```bash
ssh -i datacenter-kp.pem ec2-user@<instance-ip>
```

##### 2. **Protocol Negotiation**
```
Client                           Server
  |                               |
  |---- SSH Protocol Version ----> |
  |<--- Supported Algorithms ----- |
  |---- Selected Algorithms -----> |
```

##### 3. **Key Exchange**
```
Client                           Server
  |                               |
  |---- Client Public Key ID ----> |
  |                               | (Check ~/.ssh/authorized_keys)
  |<------ Challenge Data ------- |
  | (Sign with private key)       |
  |---- Signature Response -----> |
  |                               | (Verify with public key)
  |<------- Session Established - |
```

##### 4. **Secure Shell Session**
```
All subsequent communication encrypted using session keys
derived from the authentication handshake
```

### Key Security Architecture

#### Multi-Layer Security Model

##### 1. **File System Permissions**
```bash
# Private key security
-rw------- 1 user user  1675 Nov  9 10:00 datacenter-kp.pem
    ↑
    └── Only owner can read/write (600)

# Public key security
-rw-r--r-- 1 ec2-user ec2-user  398 Nov  9 10:00 authorized_keys
    ↑
    └── Owner write, all read (644)
```

##### 2. **SSH Daemon Configuration**
```bash
# /etc/ssh/sshd_config
PubkeyAuthentication yes          # Enable key auth
PasswordAuthentication no         # Disable password auth
PermitRootLogin no               # Disable root login
StrictModes yes                  # Enforce file permissions
```

##### 3. **Network Security**
```
Internet → Security Group → Network ACL → Instance SSH Daemon
    ↑           ↑              ↑              ↑
    |           |              |              └── Application layer
    |           |              └──────────────── Subnet layer
    |           └─────────────────────────────── Instance layer
    └─────────────────────────────────────────── Global access
```

## Amazon Machine Images (AMI)

### Understanding AMI: ami-0c101f26f147fa7fd

#### What is an AMI?

**Amazon Machine Image (AMI)** is a template that contains:
- **Operating System**: Linux, Windows, etc.
- **Application Server**: Web servers, databases, etc.
- **Applications**: Pre-installed software
- **Configuration**: System settings and customizations

#### AMI Structure
```
AMI Components:
├── Root Volume Snapshot
│   ├── Operating System Files
│   ├── System Configurations
│   └── Pre-installed Software
├── Block Device Mapping
│   ├── Root Device (/dev/xvda1)
│   └── Additional Volumes
├── Launch Permissions
│   ├── Public/Private
│   └── Account Restrictions
└── Metadata
    ├── Architecture (x86_64/arm64)
    ├── Virtualization Type
    └── Creation Date
```

### Why This Specific AMI?

#### AMI: ami-0c101f26f147fa7fd Analysis

##### 1. **Amazon Linux Distribution**
```
Amazon Linux 2:
├── Based on Red Hat Enterprise Linux
├── Optimized for AWS EC2
├── Includes AWS CLI and tools
├── Regular security updates
├── AWS Support included
└── Cost-effective licensing
```

##### 2. **Built-in AWS Integration**
```
Pre-installed Components:
├── AWS CLI (aws command)
├── AWS Systems Manager Agent
├── CloudWatch Agent
├── AWS CodeDeploy Agent
├── Docker (optional)
└── Python 3 with boto3
```

##### 3. **Security Features**
```
Security Hardening:
├── SELinux enabled by default
├── Automatic security updates
├── AWS security patches
├── Minimal package installation
├── Secure default configurations
└── Regular vulnerability scanning
```

#### AMI Selection Rationale

##### Why Not Other AMIs?

| AMI Type | Pros | Cons | Use Case |
|----------|------|------|----------|
| **Amazon Linux** | AWS optimized, free | Amazon-specific | General AWS workloads |
| **Ubuntu** | Popular, community support | Manual AWS optimization | Development environments |
| **RHEL** | Enterprise support | License costs | Enterprise applications |
| **Windows** | Microsoft ecosystem | Higher costs, licensing | .NET applications |
| **Custom AMI** | Fully customized | Maintenance overhead | Specialized workloads |

### AMI Lifecycle and Management

#### AMI Creation Process
```
Source Instance → Create Image → AMI Registration → Launch New Instances
       ↓               ↓              ↓                    ↓
   Stop Instance → Snapshot Root → Store Metadata → Copy AMI Settings
```

#### Version Management
```
ami-0c101f26f147fa7fd (Current)
├── Creation Date: 2024-XX-XX
├── Amazon Linux 2 Version: X.X
├── Kernel Version: X.X.X
├── Security Patches: Up to date
└── Package Versions:
    ├── aws-cli: X.X.X
    ├── python3: 3.X.X
    └── systemd: XXX
```

## Instance Types and Sizing

### Understanding t2.micro

#### T2 Instance Family

**T2 instances** provide burstable performance and are ideal for workloads with variable CPU requirements.

##### T2 Architecture
```
T2 Instance Components:
├── Baseline CPU Performance
│   ├── t2.micro:  10% of vCPU
│   ├── t2.small:  20% of vCPU
│   └── t2.medium: 20% of vCPU
├── CPU Credits System
│   ├── Earn credits when below baseline
│   ├── Spend credits when above baseline
│   └── Credit balance monitoring
└── Burstable Performance
    ├── Up to 100% vCPU when needed
    ├── Time-limited bursting
    └── Automatic throttling
```

#### t2.micro Specifications

##### Compute Resources
```
t2.micro Instance:
├── vCPUs: 1 (Intel Xeon family)
├── Memory: 1 GiB
├── Network Performance: Low to Moderate
├── CPU Credits/hour: 6
├── Baseline Performance: 10% of vCPU
├── Maximum Credit Balance: 144
└── Burst Duration: ~24 hours at max
```

##### Cost Analysis
```
AWS Free Tier:
├── 750 hours/month of t2.micro
├── Available for 12 months
├── Perfect for learning/testing
└── Estimated cost: ~$8.5/month after free tier

Resource Efficiency:
├── CPU: Sufficient for light workloads
├── Memory: Adequate for basic applications
├── Network: Good for development
└── Storage: EBS-optimized available
```

### CPU Credits System Deep Dive

#### How CPU Credits Work

##### Credit Earning and Spending
```
CPU Usage vs Credits:
10% usage (baseline) → Earning credits
50% usage           → Spending credits faster
100% usage          → Maximum spending rate

Credit Balance:
0 credits    → Throttled to baseline (10%)
144 credits  → Can burst for 24 hours at 100%
```

##### Monitoring CPU Credits
```bash
# CloudWatch metrics for CPU credits
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUCreditBalance \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time 2024-11-09T00:00:00Z \
  --end-time 2024-11-09T23:59:59Z \
  --period 3600 \
  --statistics Average
```

#### When t2.micro is Appropriate

##### Ideal Workloads
```
✅ Good for t2.micro:
├── Development environments
├── Code repositories (Git servers)
├── Low-traffic websites
├── Configuration management
├── Monitoring agents
├── Batch processing (intermittent)
└── Learning/experimentation

❌ Not suitable for t2.micro:
├── High-traffic web servers
├── Database servers
├── Video processing
├── Machine learning training
├── Continuous high CPU workloads
└── Memory-intensive applications
```

### Alternative Instance Types

#### When to Upgrade

##### Instance Type Progression
```
Development Lifecycle:
t2.micro (Learning) → t2.small (Testing) → t3.medium (Staging) → m5.large (Production)
    ↓                     ↓                      ↓                      ↓
10% baseline          20% baseline         Unlimited burst      Dedicated CPU
1 GiB RAM             2 GiB RAM           4 GiB RAM            8 GiB RAM
```

##### Workload-Based Selection
```
Web Applications:
├── t3.small: Light traffic
├── t3.medium: Moderate traffic
├── m5.large: Heavy traffic
└── c5.xlarge: CPU-intensive

Databases:
├── t3.medium: Development
├── m5.large: Small production
├── r5.xlarge: Memory-intensive
└── i3.large: High I/O

Machine Learning:
├── p3.2xlarge: GPU training
├── m5.4xlarge: CPU inference
├── r5.12xlarge: Large datasets
└── inf1.xlarge: AWS Inferentia
```

## Security Groups and Network Security

### Default Security Group Analysis

#### What is the Default Security Group?

Every VPC comes with a **default security group** that acts as a baseline firewall configuration.

##### Default Security Group Rules
```
Inbound Rules (Default):
├── Type: All Traffic
├── Protocol: All
├── Port Range: All
├── Source: Default Security Group ID (self-referencing)
└── Description: Default rule for same security group

Outbound Rules (Default):
├── Type: All Traffic
├── Protocol: All  
├── Port Range: All
├── Destination: 0.0.0.0/0 (anywhere)
└── Description: Allow all outbound traffic
```

#### Security Group vs Network ACL

##### Comparison Table

| Feature | Security Group | Network ACL |
|---------|----------------|-------------|
| **Level** | Instance level | Subnet level |
| **Rules** | Allow only | Allow + Deny |
| **State** | Stateful | Stateless |
| **Evaluation** | All rules | Rules in order |
| **Default** | Deny all inbound | Allow all |
| **Association** | Multiple per instance | One per subnet |

##### Security Group Operation
```
Inbound Request Flow:
Internet → Route Table → Network ACL → Security Group → Instance
    ↓           ↓             ↓             ↓           ↓
Allow all   Route exists   Allow rule    Allow rule   Accept
```

### Why Use Default Security Group?

#### Challenge Requirements Context

##### 1. **Simplicity for Learning**
```
Challenge Focus:
├── EC2 instance creation ✓
├── Key pair management ✓
├── AMI selection ✓
├── Basic networking ✓
└── Advanced security ⏸ (Future challenges)
```

##### 2. **Default Security Group Benefits**
```
Advantages:
├── Pre-exists in every VPC
├── Self-referencing rules
├── Allows communication between instances
├── Outbound internet access
└── No additional configuration needed

Limitations:
├── No SSH access from internet
├── No HTTP/HTTPS access
├── Only internal communication
└── Not suitable for public services
```

#### Security Implications

##### Default Security Group Access Pattern
```
Communication Matrix:
┌─────────────┬──────────────┬─────────────┬──────────────┐
│   Source    │   Instance   │   Internet  │  Other VPCs  │
├─────────────┼──────────────┼─────────────┼──────────────┤
│ Same SG     │      ✅      │     ❌      │      ❌      │
│ Instance    │      ✅      │     ✅      │      ❌      │
│ Internet    │      ❌      │     N/A     │     N/A      │
│ Other VPCs  │      ❌      │     N/A     │     N/A      │
└─────────────┴──────────────┴─────────────┴──────────────┘
```

##### SSH Access Consideration
```bash
# With default security group, SSH access requires:
# 1. Session Manager (AWS Systems Manager)
aws ssm start-session --target i-1234567890abcdef0

# 2. VPC Bastion Host (in same security group)
ssh -i key.pem ec2-user@bastion-host
ssh ec2-user@private-instance

# 3. Modify security group (add SSH rule)
aws ec2 authorize-security-group-ingress \
  --group-id sg-12345678 \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```

### Security Group Best Practices

#### Production Security Group Design

##### 1. **Layered Security Approach**
```hcl
# Web tier security group
resource "aws_security_group" "web_tier" {
  name_prefix = "web-tier-"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Public HTTP access
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Public HTTPS access
  }
}

# Application tier security group
resource "aws_security_group" "app_tier" {
  name_prefix = "app-tier-"
  
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier.id]  # Only from web tier
  }
}

# Database tier security group
resource "aws_security_group" "db_tier" {
  name_prefix = "db-tier-"
  
  ingress {
    from_port       = 3306  
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id]  # Only from app tier
  }
}
```

##### 2. **Administrative Access Pattern**
```hcl
# Bastion host security group
resource "aws_security_group" "bastion" {
  name_prefix = "bastion-"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]  # Office network only
  }
}

# Internal SSH access
resource "aws_security_group" "internal_ssh" {
  name_prefix = "internal-ssh-"
  
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]  # Only from bastion
  }
}
```

## Terraform Resource Configuration

### Resource Dependencies and Relationships

#### Dependency Graph Analysis

```
Resource Dependency Chain:
tls_private_key.datacenter_key
    ↓ (public_key_openssh)
aws_key_pair.datacenter_kp
    ↓ (key_name)
aws_instance.datacenter_ec2
    ↑ (vpc_security_group_ids)
data.aws_security_group.default
    ↑ (vpc_id)
data.aws_vpc.default
```

#### Implicit vs Explicit Dependencies

##### Implicit Dependencies (Terraform detects automatically)
```hcl
# Terraform automatically knows:
# aws_instance depends on aws_key_pair (key_name reference)
# aws_key_pair depends on tls_private_key (public_key reference)
# aws_security_group depends on aws_vpc (vpc_id reference)

resource "aws_instance" "datacenter_ec2" {
  key_name = aws_key_pair.datacenter_kp.key_name  # Implicit dependency
}
```

##### Explicit Dependencies (When needed)
```hcl
# Sometimes you need to force dependency order:
resource "aws_instance" "datacenter_ec2" {
  # ... other configuration ...
  
  depends_on = [
    aws_key_pair.datacenter_kp,  # Explicit dependency
    data.aws_security_group.default
  ]
}
```

### Data Sources vs Resources

#### Understanding the Difference

##### Data Sources (Read existing resources)
```hcl
# Query existing AWS resources
data "aws_vpc" "default" {
  default = true  # Find the default VPC
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id  # Use data from above
}
```

**Characteristics:**
- Read-only operations
- Don't create or modify resources
- Query existing AWS infrastructure
- Refresh data on each plan/apply

##### Resources (Create/manage resources)
```hcl
# Create new AWS resources
resource "aws_key_pair" "datacenter_kp" {
  key_name   = "datacenter-kp"
  public_key = tls_private_key.datacenter_key.public_key_openssh
}
```

**Characteristics:**
- Create, update, destroy resources
- Managed in Terraform state
- Represent desired infrastructure state
- Have lifecycle management

### TLS Provider Integration

#### Why Use TLS Provider?

##### 1. **Integrated Key Generation**
```hcl
# Alternative: Manual key generation
# ssh-keygen -t rsa -b 2048 -f datacenter-kp
# aws ec2 import-key-pair --key-name datacenter-kp --public-key-material file://datacenter-kp.pub

# Terraform approach: Automatic and integrated
resource "tls_private_key" "datacenter_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
```

##### 2. **Advantages of TLS Provider**
```
Benefits:
├── Automated key generation
├── Consistent with infrastructure lifecycle
├── No external dependencies
├── Cross-platform compatibility
├── Version controlled configuration
└── Reproducible deployments

Considerations:
├── Private key in Terraform state
├── State file security critical
├── Not suitable for production secrets
├── Consider external key management
└── Backup and recovery planning
```

#### TLS Resource Configuration

##### Key Generation Parameters
```hcl
resource "tls_private_key" "datacenter_key" {
  algorithm = "RSA"     # Algorithm type
  rsa_bits  = 2048      # Key strength
  
  # Alternative algorithms:
  # algorithm = "ECDSA"
  # ecdsa_curve = "P384"
  
  # algorithm = "ED25519"  # Most modern and secure
}
```

##### Generated Outputs
```hcl
# Available attributes from tls_private_key:
tls_private_key.datacenter_key.private_key_pem      # PEM format private key
tls_private_key.datacenter_key.public_key_pem       # PEM format public key  
tls_private_key.datacenter_key.private_key_openssh  # OpenSSH private key
tls_private_key.datacenter_key.public_key_openssh   # OpenSSH public key
tls_private_key.datacenter_key.public_key_fingerprint_md5  # MD5 fingerprint
```

### Output Configuration Strategy

#### Why Include Outputs?

##### 1. **Operational Information**
```hcl
output "instance_id" {
  value       = aws_instance.datacenter_ec2.id
  description = "EC2 instance ID for reference and management"
}

output "instance_public_ip" {
  value       = aws_instance.datacenter_ec2.public_ip
  description = "Public IP address for SSH access"
}
```

##### 2. **SSH Connection Convenience**
```hcl
output "ssh_connection_command" {
  value = "ssh -i datacenter-kp.pem ec2-user@${aws_instance.datacenter_ec2.public_ip}"
  description = "Ready-to-use SSH command"
}
```

##### 3. **Sensitive Data Handling**
```hcl
output "private_key_pem" {
  value     = tls_private_key.datacenter_key.private_key_pem
  sensitive = true    # Prevents display in console output
  description = "Private key for SSH access (save to file)"
}
```

#### Output Usage Patterns

##### Accessing Outputs
```bash
# View all outputs
terraform output

# View specific output
terraform output instance_public_ip

# View sensitive output
terraform output -raw private_key_pem

# Save private key to file
terraform output -raw private_key_pem > datacenter-kp.pem
chmod 600 datacenter-kp.pem
```

##### Output Integration
```bash
# Use outputs in scripts
INSTANCE_IP=$(terraform output -raw instance_public_ip)
ssh -i datacenter-kp.pem ec2-user@$INSTANCE_IP

# Integration with other tools
terraform output -json | jq '.instance_id.value'
```

## Security Best Practices

### Key Management Security

#### Private Key Security

##### 1. **File System Security**
```bash
# Correct private key permissions
chmod 600 datacenter-kp.pem         # Owner read/write only
chown $USER:$USER datacenter-kp.pem # Correct ownership

# Verify permissions
ls -la datacenter-kp.pem
# Expected: -rw------- 1 user user 1675 Nov  9 10:00 datacenter-kp.pem
```

##### 2. **Storage Security**
```bash
# Secure storage locations
~/.ssh/               # User SSH directory (preferred)
/etc/ssh/keys/        # System-wide keys (admin only)
~/secure/keys/        # Dedicated key directory

# Avoid insecure locations
/tmp/                 # Temporary files (accessible to all)
~/Downloads/          # Often publicly readable
~/Desktop/            # Visible and accessible
/var/www/             # Web accessible directories
```

##### 3. **Key Rotation Strategy**
```bash
# Regular key rotation (quarterly/annually)
# 1. Generate new key pair
terraform apply -var="key_rotation_date=$(date +%Y%m%d)"

# 2. Update instances with new key
# 3. Remove old key from authorized_keys
# 4. Delete old private key
```

#### State File Security

##### 1. **Remote State Configuration**
```hcl
# terraform/backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "ec2-instances/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true                    # Encrypt at rest
    dynamodb_table = "terraform-state-lock" # State locking
  }
}
```

##### 2. **State Access Control**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/TerraformRole"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-terraform-state-bucket/*"
    }
  ]
}
```

##### 3. **Local State Security**
```bash
# If using local state (development only)
chmod 600 terraform.tfstate*    # Restrict access
echo "*.tfstate*" >> .gitignore # Never commit to version control
```

### Network Security Layers

#### 1. **Security Group Configuration**
```hcl
# Production security group example
resource "aws_security_group" "production_web" {
  name_prefix = "prod-web-"
  description = "Production web server security group"
  
  # HTTP access (consider HTTPS only)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }
  
  # HTTPS access (recommended)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"  
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }
  
  # SSH access (restricted)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]  # Office network only
    description = "SSH from office network"
  }
  
  # Outbound access (specific)
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
}
```

#### 2. **Network ACL Integration**
```hcl
# Network ACL for additional subnet-level security
resource "aws_network_acl" "web_tier" {
  vpc_id = data.aws_vpc.default.id
  
  # Allow HTTP inbound
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }
  
  # Deny all other inbound by default
  ingress {
    rule_no    = 32767
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"  
    action     = "deny"
  }
}
```

#### 3. **VPC Flow Logs**
```hcl
# Monitor network traffic
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = data.aws_vpc.default.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "/aws/vpc/flowlogs"
  retention_in_days = 30
}
```

### Instance Security Hardening

#### 1. **User Data Security**
```hcl
resource "aws_instance" "secure_instance" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.datacenter_kp.key_name
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    admin_users = ["alice", "bob"]
    ssh_keys    = [tls_private_key.datacenter_key.public_key_openssh]
  }))
  
  user_data_replace_on_change = true
}
```

##### user_data.sh Template
```bash
#!/bin/bash
# Security hardening script

# Update system
yum update -y

# Configure SSH
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# Configure firewall
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Install security tools
yum install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Set up logging
echo "*.* @@logs.company.com:514" >> /etc/rsyslog.conf
systemctl restart rsyslog
```

#### 2. **IAM Role Integration**
```hcl
# IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
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

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "datacenter-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Attach role to instance
resource "aws_instance" "datacenter_ec2" {
  # ... other configuration ...
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
}
```

#### 3. **Monitoring and Alerting**
```hcl
# CloudWatch monitoring
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "datacenter-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  
  dimensions = {
    InstanceId = aws_instance.datacenter_ec2.id
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
}
```

## Production Considerations

### Scalability Planning

#### 1. **Auto Scaling Integration**
```hcl
# Launch template for auto scaling
resource "aws_launch_template" "datacenter_template" {
  name_prefix   = "datacenter-"
  image_id      = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.datacenter_kp.key_name
  
  vpc_security_group_ids = [aws_security_group.web_tier.id]
  
  user_data = base64encode(file("user_data.sh"))
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "datacenter-asg-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "datacenter_asg" {
  name                = "datacenter-asg"
  vpc_zone_identifier = [data.aws_subnet.default.id]
  target_group_arns   = [aws_lb_target_group.datacenter_tg.arn]
  health_check_type   = "ELB"
  
  min_size         = 1
  max_size         = 3
  desired_capacity = 2
  
  launch_template {
    id      = aws_launch_template.datacenter_template.id
    version = "$Latest"
  }
}
```

#### 2. **Load Balancer Integration**
```hcl
# Application Load Balancer
resource "aws_lb" "datacenter_alb" {
  name               = "datacenter-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids
  
  enable_deletion_protection = false
}

# Target Group
resource "aws_lb_target_group" "datacenter_tg" {
  name     = "datacenter-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }
}
```

### Disaster Recovery

#### 1. **Multi-AZ Deployment**
```hcl
# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Launch instances in multiple AZs
resource "aws_instance" "datacenter_ec2" {
  count             = length(data.aws_availability_zones.available.names)
  ami               = "ami-0c101f26f147fa7fd"
  instance_type     = "t2.micro"
  key_name          = aws_key_pair.datacenter_kp.key_name
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "datacenter-ec2-${count.index + 1}"
    AZ   = data.aws_availability_zones.available.names[count.index]
  }
}
```

#### 2. **Backup Strategy**
```hcl
# EBS volume for persistent data
resource "aws_ebs_volume" "datacenter_data" {
  availability_zone = aws_instance.datacenter_ec2.availability_zone
  size              = 20
  type              = "gp3"
  encrypted         = true
  
  tags = {
    Name = "datacenter-data-volume"
  }
}

# Attach volume to instance
resource "aws_volume_attachment" "datacenter_data_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.datacenter_data.id
  instance_id = aws_instance.datacenter_ec2.id
}

# Automated snapshots
resource "aws_ebs_snapshot" "datacenter_snapshot" {
  volume_id   = aws_ebs_volume.datacenter_data.id
  description = "Datacenter data volume snapshot"
  
  tags = {
    Name = "datacenter-snapshot-${formatdate("YYYY-MM-DD", timestamp())}"
  }
}
```

### Cost Optimization

#### 1. **Reserved Instances Strategy**
```hcl
# Reserved Instance planning
locals {
  instance_types = {
    development = "t2.micro"    # Free tier eligible
    staging     = "t2.small"   # Burstable for testing
    production  = "t3.medium"  # Consistent performance
  }
  
  environment = "development"  # Change based on deployment
}

resource "aws_instance" "datacenter_ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = local.instance_types[local.environment]
  # ... rest of configuration
}
```

#### 2. **Spot Instance Integration**
```hcl
# Spot instance for cost savings (non-critical workloads)
resource "aws_spot_instance_request" "datacenter_spot" {
  ami                  = "ami-0c101f26f147fa7fd"
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.datacenter_kp.key_name
  spot_price           = "0.01"  # Maximum price per hour
  wait_for_fulfillment = true
  
  tags = {
    Name = "datacenter-spot-instance"
  }
}
```

### Compliance and Auditing

#### 1. **CloudTrail Integration**
```hcl
# CloudTrail for API logging
resource "aws_cloudtrail" "datacenter_trail" {
  name                          = "datacenter-trail"
  s3_bucket_name               = aws_s3_bucket.cloudtrail_bucket.bucket
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true
  
  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    data_resource {
      type   = "AWS::EC2::Instance"
      values = ["arn:aws:ec2:*:*:instance/*"]
    }
  }
}
```

#### 2. **Config Rules**
```hcl
# AWS Config for compliance monitoring
resource "aws_config_config_rule" "ec2_security_group_attached" {
  name = "ec2-security-group-attached-to-eni"
  
  source {
    owner             = "AWS"
    source_identifier = "EC2_SECURITY_GROUP_ATTACHED_TO_ENI"
  }
  
  depends_on = [aws_config_configuration_recorder.datacenter_recorder]
}
```

This comprehensive documentation provides deep insights into every aspect of Challenge 96, from basic EC2 concepts to advanced production considerations, with particular emphasis on RSA cryptography and its importance in secure cloud infrastructure management.