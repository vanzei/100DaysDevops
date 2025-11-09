# Day 097: IAM Policy Creation - Comprehensive IAM Resources Guide

## Table of Contents
1. [IAM Core Concepts](#iam-core-concepts)
2. [Policy Structure and Evaluation](#policy-structure-and-evaluation)
3. [Principal Types and Authentication](#principal-types-and-authentication)
4. [Resource ARNs and Scope](#resource-arns-and-scope)
5. [Condition Operators and Context](#condition-operators-and-context)
6. [Production IAM Architecture](#production-iam-architecture)
7. [Security Best Practices](#security-best-practices)
8. [Compliance and Auditing](#compliance-and-auditing)
9. [Monitoring and Alerting](#monitoring-and-alerting)
10. [Troubleshooting IAM Issues](#troubleshooting-iam-issues)

## IAM Core Concepts

### Identity vs Access Management

**Identity Management** encompasses:
- **Users**: Human identities with long-term credentials
- **Groups**: Collections of users for simplified permission management
- **Roles**: Temporary credential sets for AWS service interactions
- **Identity Providers**: External authentication sources (SAML, OIDC, LDAP)

**Access Management** controls:
- **Policies**: Permission documents defining allowed actions
- **Permissions Boundaries**: Upper limits on maximum permissions
- **Service Control Policies**: Organization-level permission restrictions
- **Resource-Based Policies**: Permissions attached directly to resources

### IAM Policy Types

#### 1. Identity-Based Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-bucket/*",
        "arn:aws:s3:::my-bucket"
      ]
    }
  ]
}
```
**Characteristics:**
- Attached to IAM identities (users, groups, roles)
- Define what the identity can do
- Travel with the identity across contexts

#### 2. Resource-Based Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/Bob"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```
**Characteristics:**
- Attached to AWS resources (S3 buckets, SQS queues, etc.)
- Define who can access the resource
- Cross-account access capabilities

#### 3. Permissions Boundaries
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": ["us-east-1", "us-west-2"]
        }
      }
    }
  ]
}
```
**Characteristics:**
- Define maximum permissions for an identity
- Cannot be exceeded by any attached policies
- Applied at IAM entity level

#### 4. Service Control Policies (SCP)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "ec2:InstanceType": "t2.micro"
        }
      }
    }
  ]
}
```
**Characteristics:**
- Applied at AWS Organization level
- Can only restrict, never grant permissions
- Affect all accounts in organization/unit

#### 5. Session Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::temp-bucket/*"
    }
  ]
}
```
**Characteristics:**
- Applied during temporary credential generation
- Further restrict role/session permissions
- Used with STS AssumeRole operations

### Policy Evaluation Logic

#### AWS Policy Evaluation Flow

```text
Request → Authentication → Authorization → Action/Resource Check
    ↓           ↓              ↓              ↓
Validate    Verify Identity   Check Policies   Execute Action
Credentials                Evaluation
```

#### Policy Evaluation Rules

1. **Default Deny**: All requests start as denied
2. **Explicit Deny**: Any explicit deny overrides allow
3. **SCP Restrictions**: Service control policies can deny
4. **Permissions Boundary**: Cannot exceed boundary limits
5. **Resource Policies**: Checked for cross-account access
6. **Identity Policies**: Checked for direct permissions

#### Evaluation Priority Order

```text
1. SCP Deny (highest priority)
2. Permissions Boundary Deny
3. Explicit Deny in policies
4. Resource-based policy Allow
5. Identity-based policy Allow
6. AWS managed policy Allow
7. Default Allow (lowest priority)
```

## Principal Types and Authentication

### Principal Categories

#### 1. AWS Accounts and Root Users
```json
{
  "Principal": {
    "AWS": [
      "arn:aws:iam::123456789012:root",
      "123456789012"
    ]
  }
}
```

#### 2. IAM Users
```json
{
  "Principal": {
    "AWS": [
      "arn:aws:iam::123456789012:user/Bob",
      "arn:aws:iam::123456789012:user/Alice"
    ]
  }
}
```

#### 3. IAM Roles
```json
{
  "Principal": {
    "AWS": [
      "arn:aws:iam::123456789012:role/EC2InstanceRole",
      "arn:aws:iam::123456789012:role/LambdaExecutionRole"
    ]
  }
}
```

#### 4. Federated Users
```json
{
  "Principal": {
    "Federated": [
      "arn:aws:iam::123456789012:saml-provider/MySAMLProvider",
      "arn:aws:iam::123456789012:oidc-provider/accounts.google.com"
    ]
  }
}
```

#### 5. Service Principals
```json
{
  "Principal": {
    "Service": [
      "ec2.amazonaws.com",
      "lambda.amazonaws.com",
      "s3.amazonaws.com"
    ]
  }
}
```

#### 6. Anonymous Principals
```json
{
  "Principal": "*"
}
```

### Authentication Methods

#### 1. Long-Term Credentials
- **Access Keys**: For programmatic access (CLI, SDK)
- **Password**: For console access
- **MFA Devices**: Hardware/software tokens

#### 2. Temporary Credentials
- **STS Tokens**: Short-lived credentials via AssumeRole
- **Session Tokens**: Enhanced temporary access
- **Federated Tokens**: External identity provider tokens

#### 3. Role Assumption Flow
```text
1. Principal requests role assumption
2. IAM validates permissions to assume role
3. STS generates temporary credentials
4. Principal uses temporary credentials
5. Credentials expire automatically
```

## Resource ARNs and Scope

### ARN Structure Analysis

```text
arn:aws:service:region:account-id:resource-type/resource-id/qualifier
├─── aws ──┤├─── service ─┤├─── region ─┤├─── account ─┤├─── resource ─┤
```

#### ARN Components

| Component | Description | Examples |
|-----------|-------------|----------|
| **Partition** | AWS partition | `aws`, `aws-cn`, `aws-us-gov` |
| **Service** | AWS service namespace | `s3`, `ec2`, `iam`, `rds` |
| **Region** | AWS region | `us-east-1`, `eu-west-1`, `*` |
| **Account** | AWS account ID | `123456789012`, `*` |
| **Resource** | Resource identifier | `bucket/my-bucket`, `instance/i-12345` |

### Resource Scope Patterns

#### 1. Specific Resource
```json
{
  "Resource": "arn:aws:s3:::my-bucket/my-object.txt"
}
```
**Scope**: Single S3 object

#### 2. Resource Type Wildcard
```json
{
  "Resource": "arn:aws:s3:::my-bucket/*"
}
```
**Scope**: All objects in bucket

#### 3. Account-Level Wildcard
```json
{
  "Resource": "arn:aws:s3:::my-bucket"
}
```
**Scope**: Bucket itself (not contents)

#### 4. Service-Level Wildcard
```json
{
  "Resource": "arn:aws:ec2:us-east-1:123456789012:instance/*"
}
```
**Scope**: All EC2 instances in region/account

#### 5. Global Wildcard
```json
{
  "Resource": "*"
}
```
**Scope**: All resources (dangerous!)

### Resource ARN Examples by Service

#### EC2 Resources
```json
{
  "Resource": [
    "arn:aws:ec2:us-east-1:123456789012:instance/i-1234567890abcdef0",
    "arn:aws:ec2:us-east-1:123456789012:instance/*",
    "arn:aws:ec2:*:123456789012:instance/*",
    "arn:aws:ec2:*:*:instance/*"
  ]
}
```

#### S3 Resources
```json
{
  "Resource": [
    "arn:aws:s3:::my-bucket",
    "arn:aws:s3:::my-bucket/*",
    "arn:aws:s3:::my-bucket/prefix/*",
    "arn:aws:s3:::my-bucket/folder/subfolder/*"
  ]
}
```

#### IAM Resources
```json
{
  "Resource": [
    "arn:aws:iam::123456789012:user/Bob",
    "arn:aws:iam::123456789012:group/Developers",
    "arn:aws:iam::123456789012:role/EC2Role",
    "arn:aws:iam::123456789012:policy/MyPolicy",
    "arn:aws:iam::123456789012:mfa-device/BobMFA"
  ]
}
```

## Condition Operators and Context

### Condition Context Keys

#### AWS Global Context Keys
```json
{
  "Condition": {
    "StringEquals": {
      "aws:PrincipalAccount": "123456789012",
      "aws:PrincipalArn": "arn:aws:iam::123456789012:user/Bob",
      "aws:PrincipalServiceName": "ec2.amazonaws.com",
      "aws:PrincipalServiceNamesList": ["ec2.amazonaws.com", "lambda.amazonaws.com"],
      "aws:PrincipalType": "User",
      "aws:RequestedRegion": "us-east-1",
      "aws:RequestedService": "s3"
    }
  }
}
```

#### Time-Based Conditions
```json
{
  "Condition": {
    "DateGreaterThan": {
      "aws:CurrentTime": "2024-01-01T00:00:00Z"
    },
    "DateLessThan": {
      "aws:CurrentTime": "2024-12-31T23:59:59Z"
    },
    "DateEquals": {
      "aws:CurrentTime": "2024-06-15T12:00:00Z"
    }
  }
}
```

#### IP Address Conditions
```json
{
  "Condition": {
    "IpAddress": {
      "aws:SourceIp": ["203.0.113.0/24", "198.51.100.1/32"]
    },
    "NotIpAddress": {
      "aws:SourceIp": "192.168.0.0/16"
    }
  }
}
```

#### VPC/Subnet Conditions
```json
{
  "Condition": {
    "StringEquals": {
      "aws:SourceVpc": "vpc-12345678",
      "aws:SourceVpce": "vpce-12345678"
    }
  }
}
```

### Condition Operator Types

#### String Operators
```json
{
  "StringEquals": {"aws:PrincipalAccount": "123456789012"},
  "StringNotEquals": {"aws:PrincipalAccount": "123456789012"},
  "StringEqualsIgnoreCase": {"aws:PrincipalAccount": "123456789012"},
  "StringLike": {"aws:PrincipalAccount": "12345678901*"},
  "StringNotLike": {"aws:PrincipalAccount": "12345678901*"}
}
```

#### Numeric Operators
```json
{
  "NumericEquals": {"s3:max-keys": "1000"},
  "NumericNotEquals": {"s3:max-keys": "1000"},
  "NumericLessThan": {"s3:max-keys": "1000"},
  "NumericLessThanEquals": {"s3:max-keys": "1000"},
  "NumericGreaterThan": {"s3:max-keys": "1000"},
  "NumericGreaterThanEquals": {"s3:max-keys": "1000"}
}
```

#### Date/Time Operators
```json
{
  "DateGreaterThan": {"aws:CurrentTime": "2024-01-01T00:00:00Z"},
  "DateGreaterThanEquals": {"aws:CurrentTime": "2024-01-01T00:00:00Z"},
  "DateLessThan": {"aws:CurrentTime": "2024-01-01T00:00:00Z"},
  "DateLessThanEquals": {"aws:CurrentTime": "2024-01-01T00:00:00Z"}
}
```

#### IP Address Operators
```json
{
  "IpAddress": {"aws:SourceIp": "203.0.113.0/24"},
  "NotIpAddress": {"aws:SourceIp": "192.168.0.0/16"}
}
```

#### Boolean Operators
```json
{
  "Bool": {"aws:SecureTransport": "true"}
}
```

#### ARN Operators
```json
{
  "ArnEquals": {"aws:SourceArn": "arn:aws:s3:::my-bucket"},
  "ArnLike": {"aws:SourceArn": "arn:aws:s3:::my-bucket/*"},
  "ArnNotEquals": {"aws:SourceArn": "arn:aws:s3:::my-bucket"},
  "ArnNotLike": {"aws:SourceArn": "arn:aws:s3:::my-bucket/*"}
}
```

#### Array/List Operators
```json
{
  "ForAllValues:StringEquals": {"aws:PrincipalServiceNamesList": ["ec2.amazonaws.com"]},
  "ForAnyValue:StringEquals": {"aws:PrincipalServiceNamesList": ["ec2.amazonaws.com"]},
  "ForAllValues:StringLike": {"aws:PrincipalServiceNamesList": ["ec2.amazonaws.com"]},
  "ForAnyValue:StringLike": {"aws:PrincipalServiceNamesList": ["ec2.amazonaws.com"]}
}
```

## Production IAM Architecture

### Multi-Account Strategy

#### AWS Organization Structure
```text
Root Account (Management)
├── Security Account (Centralized logging, security tools)
├── Shared Services Account (VPC, DNS, IAM roles)
├── Development Account (Dev environments)
├── Staging Account (Testing environments)
├── Production Account (Live workloads)
└── Sandbox Account (Individual experimentation)
```

#### Cross-Account Role Patterns

##### 1. OrganizationAccountAccessRole
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::MANAGEMENT-ACCOUNT:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "aws:PrincipalType": "Account"
        }
      }
    }
  ]
}
```

##### 2. Service-Specific Roles
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### Role-Based Access Control (RBAC)

#### Job Function Roles
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": ["us-east-1", "us-west-2"],
          "aws:ResourceTag/Environment": ["development", "staging"]
        }
      }
    }
  ]
}
```

#### Environment-Based Access
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::*-dev/*",
        "arn:aws:s3:::*-staging/*"
      ]
    }
  ]
}
```

### Least Privilege Implementation

#### Permission Analysis Framework

1. **Identify Required Actions**
   - Review application requirements
   - Analyze CloudTrail logs
   - Consult service documentation

2. **Determine Resource Scope**
   - Specific ARNs vs wildcards
   - Account boundaries
   - Regional restrictions

3. **Apply Conditions**
   - Time-based restrictions
   - IP address limitations
   - MFA requirements

4. **Test and Validate**
   - Use IAM policy simulator
   - Test in non-production accounts
   - Monitor for access denied errors

#### Permission Boundary Strategy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "ec2:*",
        "rds:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": ["us-east-1", "us-west-2", "eu-west-1"]
        },
        "StringNotEquals": {
          "aws:PrincipalAccount": "123456789012"
        }
      }
    }
  ]
}
```

## Security Best Practices

### Password Policies

#### Strong Password Requirements
```json
{
  "PasswordPolicy": {
    "MinimumPasswordLength": 12,
    "RequireSymbols": true,
    "RequireNumbers": true,
    "RequireUppercaseCharacters": true,
    "RequireLowercaseCharacters": true,
    "AllowUsersToChangePassword": true,
    "ExpirePasswords": true,
    "MaxPasswordAge": 90,
    "PasswordReusePrevention": 5,
    "HardExpiry": false
  }
}
```

### Multi-Factor Authentication (MFA)

#### MFA Enforcement Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyAllExceptListedIfNoMFA",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetAccountPasswordPolicy",
        "iam:GetAccountSummary",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice",
        "sts:GetSessionToken"
      ],
      "Resource": "*",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
```

### Access Key Management

#### Key Rotation Strategy
```bash
# Disable old access key
aws iam update-access-key --access-key-id AKIOLDKEY --status Inactive --user-name Bob

# Create new access key
aws iam create-access-key --user-name Bob

# Update applications with new key
# Test applications
# Delete old access key
aws iam delete-access-key --access-key-id AKIOLDKEY --user-name Bob
```

#### Access Key Age Monitoring
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:PrincipalType": "User"
        },
        "NumericGreaterThan": {
          "aws:PrincipalAccount": "90"
        }
      }
    }
  ]
}
```

### Root Account Protection

#### Root Account Restrictions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:PrincipalType": "Root"
        }
      }
    }
  ]
}
```

## Compliance and Auditing

### Compliance Frameworks

#### CIS AWS Foundations Benchmark
- **1.1**: Avoid using root account
- **1.2**: Ensure MFA is enabled for root account
- **1.4**: Ensure access keys are rotated every 90 days
- **1.5**: Ensure IAM password policy requires strong passwords
- **1.13**: Ensure MFA is enabled for all IAM users with console access

#### NIST Cybersecurity Framework
- **Identify**: Asset management, risk assessment
- **Protect**: Access control, data security
- **Detect**: Security monitoring, anomaly detection
- **Respond**: Incident response, mitigation
- **Recover**: Recovery planning, improvements

#### SOC 2 Compliance
- **Security**: Protect against unauthorized access
- **Availability**: Ensure system availability
- **Processing Integrity**: Ensure data processing accuracy
- **Confidentiality**: Protect sensitive information
- **Privacy**: Protect personal information

### Audit Trail Requirements

#### CloudTrail Configuration
```json
{
  "Name": "security-trail",
  "S3BucketName": "security-audit-logs",
  "S3KeyPrefix": "cloudtrail",
  "IncludeGlobalServiceEvents": true,
  "IsMultiRegionTrail": true,
  "EnableLogFileValidation": true,
  "CloudWatchLogsLogGroupArn": "arn:aws:logs:us-east-1:123456789012:log-group:security-trail:*",
  "CloudWatchLogsRoleArn": "arn:aws:iam::123456789012:role/CloudTrail_CloudWatchLogs_Role",
  "KmsKeyId": "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
}
```

#### Config Rules for IAM
```json
{
  "ConfigRuleName": "iam-user-unused-credentials-check",
  "Description": "Checks for IAM user credentials that have not been used within the specified number of days",
  "Source": {
    "Owner": "AWS",
    "SourceIdentifier": "IAM_USER_UNUSED_CREDENTIALS_CHECK"
  },
  "InputParameters": {
    "maxCredentialUsageAge": "90"
  }
}
```

## Monitoring and Alerting

### IAM Access Analyzer

#### Analyzer Configuration
```json
{
  "analyzerName": "AccountAnalyzer",
  "type": "ACCOUNT",
  "configuration": {
    "unusedAccess": {
      "unusedAccessAge": 90
    }
  }
}
```

#### Findings Analysis
```bash
# List findings
aws accessanalyzer list-findings --analyzer-arn arn:aws:access-analyzer:us-east-1:123456789012:analyzer/AccountAnalyzer

# Get finding details
aws accessanalyzer get-finding --analyzer-arn arn:aws:access-analyzer:us-east-1:123456789012:analyzer/AccountAnalyzer --id finding-id
```

### CloudWatch Alarms for IAM

#### Failed Authentication Attempts
```json
{
  "AlarmName": "IAM-Failed-Authentication",
  "ComparisonOperator": "GreaterThanThreshold",
  "EvaluationPeriods": 1,
  "MetricName": "ConsoleLoginFailureCount",
  "Namespace": "AWS/IAM",
  "Period": 300,
  "Statistic": "Sum",
  "Threshold": 3,
  "ActionsEnabled": true,
  "AlarmActions": [
    "arn:aws:sns:us-east-1:123456789012:security-alerts"
  ]
}
```

#### Root Account Usage
```json
{
  "AlarmName": "Root-Account-Usage",
  "ComparisonOperator": "GreaterThanThreshold",
  "EvaluationPeriods": 1,
  "MetricName": "RootLoginEventCount",
  "Namespace": "AWS/IAM",
  "Period": 300,
  "Statistic": "Sum",
  "Threshold": 0,
  "ActionsEnabled": true,
  "AlarmActions": [
    "arn:aws:sns:us-east-1:123456789012:security-alerts"
  ]
}
```

### Security Hub Integration

#### IAM Security Standards
```json
{
  "Standards": [
    {
      "StandardsArn": "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0",
      "EnabledByDefault": true
    },
    {
      "StandardsArn": "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0",
      "EnabledByDefault": true
    }
  ]
}
```

## Troubleshooting IAM Issues

### Common Error Patterns

#### Access Denied Errors

##### 1. Policy Evaluation Issues
```bash
# Check effective permissions
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/Bob \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::my-bucket/my-object

# Check attached policies
aws iam list-attached-user-policies --user-name Bob
aws iam list-user-policies --user-name Bob
```

##### 2. SCP Restrictions
```bash
# Check organization policies
aws organizations list-policies --filter SERVICE_CONTROL_POLICY
aws organizations describe-policy --policy-id p-xxxxxxxxx
```

##### 3. Permissions Boundary Checks
```bash
# Check permissions boundary
aws iam get-user --user-name Bob
aws iam get-role --role-name MyRole
```

#### Authentication Issues

##### 1. MFA Problems
```bash
# List MFA devices
aws iam list-mfa-devices --user-name Bob

# Check MFA status
aws iam list-virtual-mfa-devices
```

##### 2. Password Policy Issues
```bash
# Check password policy
aws iam get-account-password-policy

# Update password
aws iam update-login-profile --user-name Bob --password-reset-required
```

#### Role Assumption Problems

##### 1. Trust Relationship Issues
```bash
# Check role trust policy
aws iam get-role --role-name MyRole --query 'Role.AssumeRolePolicyDocument'

# Update trust policy
aws iam update-assume-role-policy --role-name MyRole --policy-document file://trust-policy.json
```

##### 2. Session Policy Conflicts
```bash
# Test role assumption
aws sts assume-role --role-arn arn:aws:iam::123456789012:role/MyRole --role-session-name test-session

# Check session policies
aws sts get-access-key-info --access-key-id AKIATEST
```

### Debugging Tools

#### IAM Policy Simulator
```bash
# Simulate policy evaluation
aws iam simulate-custom-policy \
  --policy-input-list file://policy.json \
  --action-names s3:GetObject ec2:DescribeInstances \
  --resource-arns arn:aws:s3:::my-bucket/* arn:aws:ec2:us-east-1:123456789012:instance/*

# Simulate principal policy
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/Bob \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::my-bucket/my-object
```

#### CloudTrail Event Analysis
```bash
# Search for access denied events
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole \
  --start-time 2024-01-01T00:00:00Z

# Get specific event details
aws cloudtrail get-event-selectors --trail-name security-trail
```

#### IAM Access Advisor
```bash
# Check service permissions used
aws iam generate-service-last-accessed-details --arn arn:aws:iam::123456789012:user/Bob

# Get access details
aws iam get-service-last-accessed-details --job-id job-id
```

### Performance Optimization

#### Policy Size Limits
- **Managed Policies**: 6,144 characters
- **Inline Policies**: 10,240 characters
- **Policy Documents**: 2,048 characters per statement

#### Best Practices for Large Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3ReadOnly",
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "EC2ReadOnly",
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
```

### Incident Response

#### IAM Security Incident Response
1. **Isolate Compromised Credentials**
   - Disable access keys
   - Remove IAM user/group memberships
   - Revoke active sessions

2. **Investigate Breach**
   - Review CloudTrail logs
   - Check IAM access analyzer findings
   - Analyze authentication patterns

3. **Remediate Issues**
   - Rotate all credentials
   - Update password policies
   - Implement additional MFA requirements

4. **Prevent Future Incidents**
   - Implement least privilege
   - Enable security monitoring
   - Regular policy reviews

This comprehensive IAM resources guide provides the deep technical understanding needed for implementing secure, compliant, and maintainable identity and access management in AWS environments.