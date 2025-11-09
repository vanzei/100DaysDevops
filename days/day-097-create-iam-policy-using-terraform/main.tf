# Day 097: Create IAM Policy Using Terraform
# Path: /home/bob/terraform/main.tf

# Create IAM policy for read-only EC2 access
resource "aws_iam_policy" "iampolicy_kareem" {
  name        = "iampolicy_kareem"
  description = "Read-only access to EC2 console for viewing instances, AMIs, and snapshots"
  path        = "/"

  # Policy document granting read-only EC2 permissions
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2ReadOnlyAccess"
        Effect = "Allow"
        Action = [
          # EC2 instance read permissions
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceAttribute",
          
          # AMI read permissions
          "ec2:DescribeImages",
          "ec2:DescribeImageAttribute",
          
          # Snapshot read permissions
          "ec2:DescribeSnapshots",
          "ec2:DescribeSnapshotAttribute",
          
          # Additional EC2 read permissions for console functionality
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVolumeAttribute",
          
          # Console navigation and display
          "ec2:DescribeTags",
          "ec2:DescribeReservedInstances",
          "ec2:DescribeSpotInstanceRequests",
          "ec2:DescribePlacementGroups"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "iampolicy_kareem"
    Purpose     = "EC2ReadOnlyAccess"
    Environment = "Development"
    CreatedBy   = "Terraform"
  }
}

# Output policy details
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
  value       = aws_iam_policy.iampolicy_kareem.policy_id
}

output "policy_document" {
  description = "Policy document content"
  value       = aws_iam_policy.iampolicy_kareem.policy
  sensitive   = false
}