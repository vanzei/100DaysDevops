# Day 097: IAM Policy Creation - Solution Guide

## Challenge Overview

Create an IAM policy using Terraform that provides read-only access to the EC2 console, including permissions to view instances, AMIs, and snapshots.

## Solution Architecture

### Policy Requirements
- **Read-only EC2 access**: Allow viewing EC2 resources without modification
- **Console compatibility**: Include permissions needed for EC2 console functionality
- **Resource scope**: All EC2 instances, AMIs, and snapshots in the account

### Key Components
1. **Terraform Configuration** (`main.tf`): IAM policy resource with JSON policy document
2. **Policy Document**: JSON structure defining EC2 read permissions
3. **Resource Outputs**: Policy ARN, name, and ID for reference

## Implementation Steps

### Step 1: Create Terraform Configuration

```hcl
# main.tf
resource "aws_iam_policy" "iampolicy_kareem" {
  name        = "iampolicy_kareem"
  description = "Read-only access to EC2 console including instances, AMIs, and snapshots"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeAddresses",
          "ec2:DescribeNatGateways",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeRouteTables",
          "ec2:DescribeNetworkAcls",
          "ec2:GetConsoleOutput",
          "ec2:GetConsoleScreenshot"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "iampolicy_kareem"
    Environment = "learning"
    Challenge   = "day-097"
  }
}

# Outputs
output "policy_arn" {
  description = "ARN of the created IAM policy"
  value       = aws_iam_policy.iampolicy_kareem.arn
}

output "policy_name" {
  description = "Name of the created IAM policy"
  value       = aws_iam_policy.iampolicy_kareem.name
}

output "policy_id" {
  description = "ID of the created IAM policy"
  value       = aws_iam_policy.iampolicy_kareem.id
}
```

### Step 2: Initialize Terraform

```bash
# Initialize Terraform in the working directory
terraform init

# Expected output:
# Initializing the backend...
# Initializing provider plugins...
# - Finding latest version of hashicorp/aws...
# - Installing hashicorp/aws v5.91.0...
# - Installed hashicorp/aws v5.91.0 (signed by HashiCorp)
#
# Terraform has created a lock file .terraform.lock.hcl to record the provider
# selections.
# Terraform has been successfully initialized!
```

### Step 3: Validate Configuration

```bash
# Validate the Terraform configuration
terraform validate

# Expected output:
# Success! The configuration is valid.
```

### Step 4: Plan Deployment

```bash
# Generate and review the execution plan
terraform plan

# Expected output (partial):
# Terraform used the selected providers to generate the following execution plan.
# The plan shows that Terraform will create the following resources:
#
#   # aws_iam_policy.iampolicy_kareem will be created
#   + resource "aws_iam_policy" "iampolicy_kareem" {
#       + arn         = (known after apply)
#       + description = "Read-only access to EC2 console including instances, AMIs, and snapshots"
#       + id          = (known after apply)
#       + name        = "iampolicy_kareem"
#       + path        = "/"
#       + policy      = jsonencode(
#           {
#             + Statement = [
#               + {
#                 + Action   = [
#                   + "ec2:DescribeInstances",
#                   + "ec2:DescribeImages",
#                   + "ec2:DescribeSnapshots",
#                   + ...
#                 ]
#                 + Effect   = "Allow"
#                 + Resource = "*"
#               },
#             ]
#             + Version   = "2012-10-17"
#           }
#       )
#       + policy_id   = (known after apply)
#       + tags        = {
#           + "Challenge"   = "day-097"
#           + "Environment" = "learning"
#           + "Name"        = "iampolicy_kareem"
#         }
#       + tags_all    = {
#           + "Challenge"   = "day-097"
#           + "Environment" = "learning"
#           + "Name"        = "iampolicy_kareem"
#         }
#     }
#
# Plan: 1 to add, 0 to change, 0 to destroy.
```

### Step 5: Deploy the Policy

```bash
# Apply the configuration to create the IAM policy
terraform apply

# Expected output (partial):
# aws_iam_policy.iampolicy_kareem: Creating...
# aws_iam_policy.iampolicy_kareem: Creation complete after 2s [id=arn:aws:iam::123456789012:policy/iampolicy_kareem]
#
# Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
#
# Outputs:
#
# policy_arn = "arn:aws:iam::123456789012:policy/iampolicy_kareem"
# policy_name = "iampolicy_kareem"
# policy_id = "arn:aws:iam::123456789012:policy/iampolicy_kareem"
```

## Policy Analysis

### Included Permissions

The policy provides comprehensive read-only access to EC2 resources:

#### Core EC2 Resources
- `ec2:DescribeInstances`: View EC2 instances and their details
- `ec2:DescribeImages`: View Amazon Machine Images (AMIs)
- `ec2:DescribeSnapshots`: View EBS snapshots

#### Supporting Resources
- `ec2:DescribeVolumes`: View EBS volumes
- `ec2:DescribeKeyPairs`: View SSH key pairs
- `ec2:DescribeSecurityGroups`: View security groups
- `ec2:DescribeSubnets`: View subnets
- `ec2:DescribeVpcs`: View VPCs

#### Network Resources
- `ec2:DescribeNetworkInterfaces`: View ENIs
- `ec2:DescribeAddresses`: View Elastic IPs
- `ec2:DescribeNatGateways`: View NAT gateways
- `ec2:DescribeVpcEndpoints`: View VPC endpoints
- `ec2:DescribeInternetGateways`: View internet gateways
- `ec2:DescribeRouteTables`: View route tables
- `ec2:DescribeNetworkAcls`: View network ACLs

#### Console Features
- `ec2:GetConsoleOutput`: View instance system logs
- `ec2:GetConsoleScreenshot`: View instance screenshots

### Resource Scope

The policy uses `Resource = "*"` which allows access to all EC2 resources in the account. This is appropriate for read-only policies as it doesn't pose security risks.

## Testing the Policy

### Method 1: IAM Policy Simulator

```bash
# Test the policy using AWS CLI
aws iam simulate-custom-policy \
  --policy-input-list file://policy.json \
  --action-names ec2:DescribeInstances ec2:DescribeImages ec2:DescribeSnapshots \
  --resource-arns "*"

# Expected output:
# {
#     "EvaluationResults": [
#         {
#             "EvalActionName": "ec2:DescribeInstances",
#             "EvalResourceName": "*",
#             "EvalDecision": "allowed",
#             "MatchedStatements": [
#                 {
#                     "SourcePolicyId": "PolicyInputList1",
#                     "StatementId": "VisualEditor0",
#                     "Effect": "Allow"
#                 }
#             ]
#         }
#     ]
# }
```

### Method 2: Attach to Test User

```bash
# Create a test user (if not exists)
aws iam create-user --user-name test-ec2-readonly-user

# Attach the policy to the test user
aws iam attach-user-policy \
  --user-name test-ec2-readonly-user \
  --policy-arn arn:aws:iam::123456789012:policy/iampolicy_kareem

# Create access keys for testing
aws iam create-access-key --user-name test-ec2-readonly-user

# Test EC2 describe operations
aws ec2 describe-instances --region us-east-1
aws ec2 describe-images --owners amazon --region us-east-1
aws ec2 describe-snapshots --owner-ids self --region us-east-1
```

### Method 3: Console Testing

1. **Create Test User**: Use the AWS Management Console to create a test user
2. **Attach Policy**: Attach the `iampolicy_kareem` policy to the test user
3. **Test Console Access**:
   - Log in as the test user
   - Navigate to EC2 console
   - Verify you can view instances, AMIs, and snapshots
   - Confirm you cannot create, modify, or delete resources

## Verification Commands

### Check Policy Creation

```bash
# List all IAM policies
aws iam list-policies --scope Local

# Get policy details
aws iam get-policy --policy-arn arn:aws:iam::123456789012:policy/iampolicy_kareem

# Get policy version
aws iam get-policy-version \
  --policy-arn arn:aws:iam::123456789012:policy/iampolicy_kareem \
  --version-id v1
```

### Validate Policy Structure

```bash
# Extract and validate JSON
aws iam get-policy-version \
  --policy-arn arn:aws:iam::123456789012:policy/iampolicy_kareem \
  --version-id v1 \
  --query 'PolicyVersion.Document' \
  --output json | jq .
```

## Troubleshooting

### Common Issues

#### 1. Policy Creation Fails
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify region configuration
aws configure list

# Check IAM permissions for policy creation
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/YourUser \
  --action-names iam:CreatePolicy
```

#### 2. Access Denied Errors
```bash
# Check if policy is properly attached
aws iam list-attached-user-policies --user-name test-user

# Verify policy document syntax
aws iam get-policy-version \
  --policy-arn arn:aws:iam::123456789012:policy/iampolicy_kareem \
  --version-id v1
```

#### 3. Terraform State Issues
```bash
# Check Terraform state
terraform state list

# Refresh state
terraform refresh

# Reconcile state with reality
terraform plan -refresh-only
```

### Debugging Steps

1. **Validate JSON Syntax**: Use `jq` to validate policy document
2. **Check AWS Limits**: Ensure you haven't exceeded IAM policy limits
3. **Review CloudTrail**: Check CloudTrail logs for policy creation events
4. **Test with Minimal Policy**: Start with a single permission to isolate issues

## Production Deployment Considerations

### Security Best Practices

#### 1. Principle of Least Privilege
- Regularly review and remove unnecessary permissions
- Use IAM Access Analyzer to identify unused permissions
- Implement permission boundaries for additional restrictions

#### 2. Policy Organization
```hcl
# Use consistent naming conventions
resource "aws_iam_policy" "ec2_readonly" {
  name = "EC2ReadOnly-${var.environment}"
  # ... policy definition
}

# Group related permissions
resource "aws_iam_policy" "ec2_console_readonly" {
  name = "EC2ConsoleReadOnly-${var.environment}"
  # ... console-specific permissions
}
```

#### 3. Tagging Strategy
```hcl
tags = {
  Name        = "iampolicy_kareem"
  Environment = var.environment
  Project     = var.project
  Owner       = var.owner
  CostCenter  = var.cost_center
}
```

### Monitoring and Compliance

#### 1. Enable CloudTrail
```hcl
resource "aws_cloudtrail" "security_trail" {
  name                          = "security-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_log_file_validation   = true
}
```

#### 2. Set Up Alerts
```hcl
resource "aws_cloudwatch_metric_alarm" "iam_policy_changes" {
  alarm_name          = "IAM-Policy-Changes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "PolicyChanges"
  namespace           = "AWS/IAM"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
}
```

### Backup and Recovery

#### 1. Policy Versioning
```bash
# List policy versions
aws iam list-policy-versions --policy-arn arn:aws:iam::123456789012:policy/iampolicy_kareem

# Create new version before changes
aws iam create-policy-version \
  --policy-arn arn:aws:iam::123456789012:policy/iampolicy_kareem \
  --policy-document file://new-policy.json \
  --set-as-default
```

#### 2. Terraform State Management
```bash
# Backup Terraform state
terraform state pull > backup.tfstate

# Use remote state for team collaboration
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "iam-policies/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Cleanup

### Remove Test Resources

```bash
# Detach policy from test user
aws iam detach-user-policy \
  --user-name test-ec2-readonly-user \
  --policy-arn arn:aws:iam::123456789012:policy/iampolicy_kareem

# Delete access keys
aws iam list-access-keys --user-name test-ec2-readonly-user
aws iam delete-access-key --user-name test-ec2-readonly-user --access-key-id AKIATEST

# Delete test user
aws iam delete-user --user-name test-ec2-readonly-user
```

### Terraform Cleanup

```bash
# Destroy all resources
terraform destroy

# Expected output:
# aws_iam_policy.iampolicy_kareem: Destroying... [id=arn:aws:iam::123456789012:policy/iampolicy_kareem]
# aws_iam_policy.iampolicy_kareem: Destruction complete after 1s
#
# Destroy complete! Resources: 1 destroyed.
```

## Key Learnings

1. **Policy Structure**: Understanding JSON policy documents and IAM policy language
2. **EC2 Permissions**: Comprehensive read-only access requires multiple Describe* actions
3. **Resource Scope**: Using wildcards appropriately for read-only policies
4. **Testing Methods**: Multiple approaches to validate policy effectiveness
5. **Production Considerations**: Security, monitoring, and compliance requirements
6. **Terraform Best Practices**: State management, tagging, and resource organization

## Next Steps

- Attach the policy to IAM users or groups requiring EC2 console read access
- Set up monitoring and alerting for policy usage
- Implement regular policy reviews and access audits
- Consider creating more granular policies for specific use cases
- Explore IAM Access Analyzer for ongoing permission analysis

This solution provides a solid foundation for IAM policy creation while demonstrating best practices for security, testing, and production deployment.