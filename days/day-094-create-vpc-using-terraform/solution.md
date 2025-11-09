# Day 094: Create VPC Using Terraform - Complete Solution

## Challenge Overview

### Requirements
- **Resource**: Create a VPC named "nautilus-vpc"
- **Region**: us-east-1
- **CIDR Block**: Any IPv4 CIDR block (we're using 10.0.0.0/16)
- **File**: main.tf (single file requirement)
- **Directory**: /home/bob/terraform
- **Tool**: Terraform

## Step-by-Step Solution

### Step 1: Navigate to Working Directory

In the KodeKloud environment, navigate to the Terraform working directory:

```bash
cd /home/bob/terraform
```

### Step 2: Create main.tf Configuration

Create the `main.tf` file with the following content:

```hcl
# Day 094: Create VPC Using Terraform
# Path: /home/bob/terraform/main.tf

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create VPC named nautilus-vpc
resource "aws_vpc" "nautilus_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "nautilus-vpc"
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

  # aws_vpc.nautilus_vpc will be created
  + resource "aws_vpc" "nautilus_vpc" {
      + arn                                  = (known after apply)
      + cidr_block                          = "10.0.0.0/16"
      + default_network_acl_id              = (known after apply)
      + default_route_table_id              = (known after apply)
      + default_security_group_id           = (known after apply)
      + dhcp_options_id                     = (known after apply)
      + enable_dns_hostnames                = true
      + enable_dns_support                  = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                  = (known after apply)
      + instance_tenancy                    = "default"
      + ipv6_association_id                 = (known after apply)
      + ipv6_cidr_block                     = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                 = (known after apply)
      + owner_id                            = (known after apply)
      + tags                                = {
          + "Name" = "nautilus-vpc"
        }
      + tags_all                            = {
          + "Name" = "nautilus-vpc"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

### Step 6: Apply the Configuration

Create the VPC:

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
aws_vpc.nautilus_vpc: Creating...
aws_vpc.nautilus_vpc: Creation complete after 2s [id=vpc-xxxxxxxxxxxxxxxxx]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

### Step 7: Verify the VPC Creation

Check the created resources:

```bash
terraform show
```

Or verify using AWS CLI:

```bash
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=nautilus-vpc" --region us-east-1
```

## Configuration Explanation

### Provider Block
```hcl
provider "aws" {
  region = "us-east-1"
}
```
- **Purpose**: Configures the AWS provider
- **Region**: Specifies us-east-1 as required
- **Authentication**: Uses default AWS credentials (IAM role in KodeKloud)

### VPC Resource Block
```hcl
resource "aws_vpc" "nautilus_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "nautilus-vpc"
  }
}
```

#### Key Attributes:
- **`cidr_block`**: IP address range for the VPC (10.0.0.0/16 provides 65,536 IP addresses)
- **`enable_dns_hostnames`**: Enables DNS hostnames for instances
- **`enable_dns_support`**: Enables DNS resolution
- **`tags`**: Labels for resource identification and management

## CIDR Block Analysis

### Chosen CIDR: 10.0.0.0/16

| Attribute | Value |
|-----------|-------|
| **Network Address** | 10.0.0.0 |
| **Subnet Mask** | 255.255.0.0 |
| **Total IP Addresses** | 65,536 |
| **Usable IP Addresses** | 65,531 (AWS reserves 5 per subnet) |
| **Address Range** | 10.0.0.0 - 10.0.255.255 |

### Why This CIDR Block?

1. **Standard Practice**: 10.0.0.0/16 is a common choice for VPCs
2. **Adequate Size**: Provides room for multiple subnets and growth
3. **RFC 1918 Compliant**: Uses private IP address space
4. **No Conflicts**: Unlikely to conflict with existing networks

## Terraform Commands Reference

### Essential Commands

```bash
# Initialize working directory
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List resources
terraform state list

# Destroy resources (cleanup)
terraform destroy
```

### Useful Options

```bash
# Auto-approve apply (use carefully)
terraform apply -auto-approve

# Save plan to file
terraform plan -out=tfplan

# Apply from saved plan
terraform apply tfplan

# Target specific resource
terraform plan -target=aws_vpc.nautilus_vpc

# Refresh state
terraform refresh
```

## Validation Steps

### 1. Terraform State Verification
```bash
# List resources in state
terraform state list

# Show VPC details
terraform state show aws_vpc.nautilus_vpc
```

### 2. AWS Console Verification
- Navigate to VPC Dashboard in AWS Console
- Verify "nautilus-vpc" appears in VPC list
- Check CIDR block is 10.0.0.0/16
- Confirm region is us-east-1

### 3. AWS CLI Verification
```bash
# List all VPCs
aws ec2 describe-vpcs --region us-east-1

# Filter for nautilus-vpc
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=nautilus-vpc" --region us-east-1

# Get VPC ID
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=nautilus-vpc" --query 'Vpcs[0].VpcId' --output text --region us-east-1
```

## Expected Results

### Successful Terraform Apply Output
```
aws_vpc.nautilus_vpc: Creating...
aws_vpc.nautilus_vpc: Creation complete after 2s [id=vpc-0123456789abcdef0]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

### VPC Properties (terraform show)
```
# aws_vpc.nautilus_vpc:
resource "aws_vpc" "nautilus_vpc" {
    arn                                  = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-0123456789abcdef0"
    assign_generated_ipv6_cidr_block     = false
    cidr_block                          = "10.0.0.0/16"
    default_network_acl_id              = "acl-0123456789abcdef0"
    default_route_table_id              = "rtb-0123456789abcdef0"
    default_security_group_id           = "sg-0123456789abcdef0"
    dhcp_options_id                     = "dopt-0123456789abcdef0"
    enable_dns_hostnames                = true
    enable_dns_support                  = true
    enable_network_address_usage_metrics = false
    id                                  = "vpc-0123456789abcdef0"
    instance_tenancy                    = "default"
    ipv6_netmask_length                 = 0
    main_route_table_id                 = "rtb-0123456789abcdef0"
    owner_id                            = "123456789012"
    tags                                = {
        "Name" = "nautilus-vpc"
    }
    tags_all                            = {
        "Name" = "nautilus-vpc"
    }
}
```

## Troubleshooting Guide

### Common Issues

#### 1. AWS Credentials Not Configured
**Error:**
```
Error: No valid credential sources found for AWS Provider
```

**Solution:**
```bash
# Check AWS configuration
aws configure list

# Verify IAM permissions
aws sts get-caller-identity
```

#### 2. Region Access Issues
**Error:**
```
Error: UnauthorizedOperation: You are not authorized to perform this operation
```

**Solution:**
- Verify IAM permissions include VPC creation
- Ensure region us-east-1 is accessible
- Check for service limits

#### 3. Terraform Not Initialized
**Error:**
```
Error: Terraform configuration must be initialized
```

**Solution:**
```bash
terraform init
```

#### 4. CIDR Block Conflicts
**Error:**
```
Error: InvalidVpc.Range: The CIDR '10.0.0.0/16' conflicts with another subnet
```

**Solution:**
- Choose a different CIDR block
- Check existing VPCs for conflicts
- Use `aws ec2 describe-vpcs` to list existing CIDRs

### Debugging Commands

```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH="./terraform.log"

# Check Terraform version
terraform version

# Validate configuration
terraform validate

# Check formatting
terraform fmt -check

# Show configuration without applying
terraform plan
```

## Cleanup (Optional)

To remove the created VPC:

```bash
terraform destroy
```

When prompted, type `yes` to confirm:

```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

## Best Practices Applied

### 1. DNS Configuration
- **`enable_dns_hostnames = true`**: Allows instances to have DNS hostnames
- **`enable_dns_support = true`**: Enables DNS resolution within VPC

### 2. Resource Tagging
- **Name tag**: Provides clear identification
- **Consistent naming**: Follows naming conventions

### 3. CIDR Planning
- **Standard range**: Uses RFC 1918 private address space
- **Adequate size**: /16 provides room for growth
- **Future-proof**: Allows for subnet creation

## Security Considerations

### Default VPC Security
When creating a VPC, AWS automatically creates:
- **Default Security Group**: Allows all inbound traffic from same security group
- **Default Network ACL**: Allows all inbound and outbound traffic
- **Default Route Table**: Routes traffic within VPC

### Production Enhancements
For production environments, consider:
- Restricting default security group rules
- Implementing custom Network ACLs
- Enabling VPC Flow Logs
- Setting up proper IAM permissions

## Next Steps (Beyond Challenge)

After completing this challenge, typical next steps would include:

1. **Create Subnets**: Public and private subnets across AZs
2. **Add Internet Gateway**: For internet connectivity
3. **Configure Route Tables**: Direct traffic appropriately
4. **Set up NAT Gateway**: For private subnet internet access
5. **Implement Security Groups**: Instance-level firewalls
6. **Add VPC Endpoints**: Private access to AWS services

This solution provides a solid foundation for AWS VPC management using Terraform while meeting all challenge requirements.