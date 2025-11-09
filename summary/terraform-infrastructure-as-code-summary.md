# Terraform Infrastructure as Code - 100 Days DevOps Challenge

## Overview

Terraform infrastructure as code was covered in Days 94-100 of the challenge, focusing on declarative infrastructure provisioning, state management, and multi-cloud deployments. This module completed the DevOps toolchain by adding infrastructure automation to the CI/CD pipeline.

## What We Practiced

### Terraform Fundamentals
- **Terraform installation** and workspace setup
- **Provider configuration** for cloud platforms
- **Resource management** and lifecycle
- **State management** and locking

### Infrastructure Provisioning
- **Module development** for reusable components
- **Variable management** and validation
- **Output handling** and data sources
- **Remote state** and team collaboration

### Advanced Features
- **Workspaces** for environment management
- **Provisioners** for configuration management
- **Import/refresh** operations for existing infrastructure
- **Graph visualization** and planning

## Key Commands Practiced

### Terraform Installation & Setup
```bash
# Install Terraform
wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip
unzip terraform_1.0.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version

# Initialize workspace
terraform init

# Format configuration
terraform fmt

# Validate configuration
terraform validate
```

### Basic Workflow
```bash
# Initialize Terraform
terraform init

# Review changes
terraform plan

# Apply changes
terraform apply

# Confirm with auto-approve
terraform apply -auto-approve

# Destroy infrastructure
terraform destroy

# Show current state
terraform show

# List resources
terraform state list
```

### State Management
```bash
# Backup state
cp terraform.tfstate terraform.tfstate.backup

# Move resources in state
terraform state mv old_resource new_resource

# Remove resource from state
terraform state rm resource_name

# Import existing resource
terraform import resource_type.resource_name resource_id

# Refresh state
terraform refresh

# Force unlock state
terraform force-unlock LOCK_ID
```

### Workspace Management
```bash
# List workspaces
terraform workspace list

# Create workspace
terraform workspace new development

# Select workspace
terraform workspace select production

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete development
```

## Technical Topics Covered

### Terraform Architecture
```text
Terraform Configuration (.tf files)
├── Variables (variables.tf)
├── Resources (main.tf)
├── Outputs (outputs.tf)
├── Providers (providers.tf)
└── Modules (modules/)

Terraform State (.tfstate)
├── Resource Mappings
├── Metadata & Dependencies
├── State Locking
└── Remote State Backend

Execution Engine
├── Graph Builder
├── Plan Generator
├── Apply Executor
└── State Manager
```

### Resource Lifecycle
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  # Create-time provisioners
  provisioner "local-exec" {
    command = "echo ${aws_instance.web.public_ip} > ip_address.txt"
  }

  # Destroy-time provisioners
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ip_address.txt"
  }

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags["LastModified"],
    ]
    prevent_destroy = false
  }

  tags = {
    Name = "WebServer"
    Environment = "production"
  }
}
```

### Module Structure
```text
terraform-modules/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── ec2/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── templates/
│       └── user_data.sh.tpl
└── rds/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

### Variable Types & Validation
```hcl
# Input variables with validation
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be one of: t2.micro, t2.small, t3.medium."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

# Complex variable types
variable "security_groups" {
  description = "Security group rules"
  type = list(object({
    name        = string
    description = string
    ingress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
  default = []
}
```

## Production Environment Considerations

### State Management & Security
- **Remote state**: Shared state with locking
- **State encryption**: Sensitive data protection
- **Backup strategies**: State file backups and recovery
- **Access controls**: State access permissions

### Security & Compliance
- **Credential management**: Secure provider authentication
- **Resource tagging**: Cost allocation and compliance
- **Network isolation**: Private networking and security groups
- **Audit logging**: Infrastructure change tracking

### Scalability & Performance
- **Module composition**: Reusable infrastructure components
- **Parallel execution**: Concurrent resource provisioning
- **Dependency management**: Resource dependency optimization
- **Caching**: Provider and module caching

### Reliability & Testing
- **Plan validation**: Change review before execution
- **Testing frameworks**: Terratest and kitchen-terraform
- **Rollback procedures**: Failed deployment recovery
- **Monitoring**: Infrastructure monitoring and alerting

## Real-World Applications

### Complete Infrastructure Stack
```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  environment        = var.environment
}

module "security" {
  source = "./modules/security"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "compute" {
  source = "./modules/compute"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security.web_sg_id]
  instance_count     = var.instance_count
  instance_type      = var.instance_type
  environment        = var.environment

  depends_on = [module.vpc, module.security]
}

module "database" {
  source = "./modules/database"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.database_subnet_ids
  security_group_ids = [module.security.db_sg_id]
  instance_class     = var.db_instance_class
  environment        = var.environment

  depends_on = [module.vpc, module.security]
}

module "load_balancer" {
  source = "./modules/load_balancer"

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnet_ids
  security_groups = [module.security.lb_sg_id]
  instances       = module.compute.instance_ids
  environment     = var.environment

  depends_on = [module.vpc, module.security, module.compute]
}
```

### Remote State Configuration
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-company-terraform-state"
    key            = "production/infrastructure.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/terraform-state-key"
    dynamodb_table = "terraform-state-locks"

    # State locking with DynamoDB
    # Table structure:
    # - Primary key: LockID (String)
    # - Attributes: Info (String)
  }
}

# Alternative backends
# Azure RM
backend "azurerm" {
  resource_group_name  = "terraform-state"
  storage_account_name = "terraformstate"
  container_name       = "tfstate"
  key                  = "infrastructure.tfstate"
}

# GCS
backend "gcs" {
  bucket = "terraform-state-bucket"
  prefix = "infrastructure"
}
```

### Multi-Environment Management
```hcl
# environments/production.tfvars
aws_region = "us-east-1"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]

instance_count = 3
instance_type  = "t3.medium"
db_instance_class = "db.t3.medium"

# environments/staging.tfvars
aws_region = "us-east-1"

vpc_cidr = "10.1.0.0/16"

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

instance_count = 1
instance_type  = "t2.micro"
db_instance_class = "db.t2.micro"

# Deployment script
#!/bin/bash
set -e

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment>"
  echo "Environments: production, staging, development"
  exit 1
fi

echo "Deploying to $ENVIRONMENT environment..."

# Select workspace
terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT

# Plan changes
terraform plan -var-file="environments/${ENVIRONMENT}.tfvars" -out=tfplan

# Apply changes
terraform apply tfplan

echo "Deployment to $ENVIRONMENT completed successfully!"
```

### VPC Module Example
```hcl
# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-${var.availability_zones[count.index]}"
    Type = "Public"
  }
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-private-${var.availability_zones[count.index]}"
    Type = "Private"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.environment}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# modules/vpc/variables.tf
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateway for private subnets"
  type        = bool
  default     = true
}

# modules/vpc/outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : null
}
```

### Testing with Terratest
```go
// test/terraform_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformInfrastructure(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../",
        VarFiles:     []string{"test.tfvars"},
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Test VPC creation
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)

    // Test subnet creation
    publicSubnetIds := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
    assert.Len(t, publicSubnetIds, 2)

    // Test security group
    webSgId := terraform.Output(t, terraformOptions, "web_security_group_id")
    assert.NotEmpty(t, webSgId)

    // Test EC2 instances
    instanceIds := terraform.OutputList(t, terraformOptions, "instance_ids")
    assert.Len(t, instanceIds, 1)

    // Test load balancer
    lbDns := terraform.Output(t, terraformOptions, "load_balancer_dns")
    assert.NotEmpty(t, lbDns)
    assert.Contains(t, lbDns, "elb.amazonaws.com")
}
```

## Troubleshooting Common Issues

### State Issues
```bash
# Check state file
terraform show

# List resources in state
terraform state list

# Fix state drift
terraform refresh
terraform plan

# Recover from corrupted state
terraform state pull > backup.tfstate
terraform state push backup.tfstate
```

### Provider Issues
```bash
# Reinitialize providers
terraform init -upgrade

# Check provider versions
terraform providers

# Clear provider cache
rm -rf .terraform/
terraform init
```

### Resource Issues
```bash
# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Taint resource for recreation
terraform taint aws_instance.web

# Untaint resource
terraform untaint aws_instance.web

# Debug resource creation
TF_LOG=DEBUG terraform apply
```

### Dependency Issues
```bash
# Show dependency graph
terraform graph

# Target specific resources
terraform plan -target=aws_instance.web
terraform apply -target=aws_instance.web

# Check for cycles
terraform graph | grep -A5 -B5 "->"
```

## Key Takeaways

1. **Declarative**: Define desired state, not procedural steps
2. **Idempotent**: Safe to run multiple times with same result
3. **Versioned**: Infrastructure changes tracked in version control
4. **Testable**: Automated testing of infrastructure code
5. **Reusable**: Modules enable component reusability

## Next Steps

- **Terragrunt**: Wrapper for Terraform with additional features
- **Pulumi**: Infrastructure as Code with programming languages
- **Crossplane**: Kubernetes-native infrastructure management
- **CDK for Terraform**: TypeScript-based Terraform configuration
- **Atlantis**: GitOps workflow for Terraform

Terraform has transformed infrastructure management, enabling teams to treat infrastructure as code with version control, testing, and automated deployments across all cloud providers.