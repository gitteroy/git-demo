# Git, CI/CD & AWS Deployment Tutorial

A hands-on tutorial for developers transitioning from personal projects to team-based development in corporate environments. This repository demonstrates professional git workflows, CI/CD pipelines, and automated AWS deployments.

## Learning Objectives

By completing this tutorial, you'll understand:

- **Git workflow** used in RAiD
- **CI/CD pipelines** with GitHub Actions
- **Infrastructure as Code** with Terraform
- **Automated AWS deployments** from GitHub
- **Team collaboration** patterns and best practices

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Architecture](#project-architecture)
- [Getting Started](#getting-started)
- [Core Concepts Explained](#core-concepts-explained)
- [Deployment Workflows Summary](#deployment-workflows-summary)
- [Hands-On Exercises](#hands-on-exercises)
  - [Exercise 1: Understanding Git Workflows](#exercise-1-understanding-git-workflows)
  - [Exercise 2: Setting Up AWS Deployment](#exercise-2-setting-up-aws-deployment)
  - [Exercise 3: Terraform Deep Dive](#exercise-3-terraform-deep-dive)
  - [Exercise 4: Application Deployments](#exercise-4-application-deployments)
  - [Exercise 5: Monitoring Your Deployment](#exercise-5-monitoring-your-deployment)
- [Troubleshooting Common Issues](#troubleshooting-common-issues)
- [Terraform Environment Management](#terraform-environment-management)
- [Testing Your Deployments](#testing-your-deployments)
- [Monitoring and Alerting](#monitoring-and-alerting)
- [Additional Resources](#additional-resources)

## Prerequisites

- Git fundamentals
- Basic programming knowledge
- AWS account with appropriate permissions
- GitHub account

## Project Architecture

This project deploys infra and apps to AWS using modern DevOps practices:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions  │───▶│   AWS Cloud     │
│                 │    │    (CI/CD)       │    │                 │
│ • Terraform     │    │ • Build & Test   │    │ • Lambda        │
│ • Lambda Code   │    │ • Deploy Infra   │    │ • API Gateway   │
│ • Workflows     │    │ • Deploy Code    │    │ • S3 Bucket     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Getting Started

### Step 1: Clone

```bash
git clone https://github.com/YOUR_USERNAME/git-demo.git
cd git-demo
```

### Step 2: Understand the Repository Structure

```sh
git-demo/
├── .github/workflows/     # CI/CD pipeline definitions
│   ├── deploy-infra.yml   # Deploys Terraform infrastructure
│   ├── deploy-lambda.yml  # Deploys Lambda function code
│   └── deploy-s3.yml      # Deploys static website
├── terraform/             # Infrastructure as Code
│   ├── modules/           # Reusable Terraform components
│   └── main.tf            # Main infrastructure definition
├── lambda/                # Serverless function code
│   ├── app.py             # Telegram bot logic
│   └── requirements.txt   # Python dependencies
└── packer/                # AMI building
```

**Key Concept:** This structure separates **infrastructure** (Terraform) from **application code** (Lambda), a best practice in professional environments.

## Core Concepts Explained

### 1. Infrastructure as Code (Terraform)

**What is it?** Instead of manually clicking in AWS console, we define infrastructure using code. This ensures:

- **Reproducibility:** Same infrastructure every time
- **Version Control:** Track infrastructure changes
- **Team Collaboration:** Everyone uses the same setup

**Example from our project:**

```hcl
# terraform/main.tf
module "telegram_bot_lambda" {
  source        = "./modules/lambda"
  function_name = var.lambda_function_name
  secret_arn    = aws_secretsmanager_secret.bot_token.arn
}
```

### 2. CI/CD with GitHub Actions

**What is CI/CD?**

- **Continuous Integration (CI):** Automatically test code when changes are made
- **Continuous Deployment (CD):** Automatically deploy tested code to production

**Our Pipeline Flow:**

1. Developer pushes code to GitHub
2. GitHub Actions detects changes
3. Runs tests and builds application
4. Deploys to AWS automatically

**Example Workflow:**

```yaml
# .github/workflows/deploy-infra.yml
on:
  push:
    branches: [main]
    paths: ['terraform/**']  # Only run when Terraform files change
```

### 3. AWS Services Used

- **Lambda:** Serverless functions (no server management needed)
- **API Gateway:** Handles HTTP requests to Lambda
- **S3:** Static website hosting
- **Secrets Manager:** Secure storage for API keys
- **IAM:** Permissions and security

## Deployment Workflows Summary

### Workflow Dependencies

```md
Terraform Infrastructure
         ↓
    ┌────────────────┐
    │   S3 Deploy    │
    │ Lambda Deploy  │
    │ Packer Build   │
    └────────────────┘
```

**Execution Order:**

1. **Infrastructure first:** Terraform creates AWS resources
2. **Applications second:** S3, Lambda, and Packer workflows run after infrastructure is ready
3. **Path-based triggers:** Each workflow only runs when relevant files change

### File Change Triggers

| Path Changed | Workflows Triggered |
|--------------|--------------------|
| `terraform/**` | Deploy Infrastructure |
| `index.html` | Deploy to S3 |
| `lambda/**` | Deploy Lambda |
| `packer/**` | Build AMI |

## Hands-On Exercises

### Exercise 1: Understanding Git Workflows

**App Teams in RAiD:** Teams use rebase workflows with feature branches and pull requests to maintain clean commit history.

**Refer to the rebase workflow steps:** [git-rebase.md](./git-rebase.md)

The workflow includes:

1. Create feature branch
2. Make changes and commits to both branches
3. Rebase onto latest main
4. Create Pull Request
5. Code review and merge

**Why this matters:** Rebase workflows create linear, clean commit history that's easier to understand and debug in corporate environments.

### Exercise 2: Setting Up AWS Deployment

**Prerequisites Setup:**

#### 1. Create GitHub OIDC Identity Provider in AWS

**What is OIDC?** OpenID Connect allows GitHub Actions to authenticate with AWS without storing long-term credentials.

**In AWS IAM Console:**

1. Go to Identity Providers: Add Provider
2. Provider Type: `OpenID Connect`
3. Provider URL: `https://token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`
5. Click "Add Provider"

**Why this works:** GitHub generates temporary JWT tokens that AWS can verify and exchange for temporary AWS credentials.

#### 2. Create IAM Role for GitHub Actions

Create role `GithubActionsRole`. The role will have 2 parts:

- Permissions (policies): what the role can do once assumed.
- Trust relationship: who (which principal) is allowed to assume the role.

1. Role

- Go with principle of least privilege
- However, we use custom admin access as a bypass because our Terraform maintains everything in AWS

2. Trust policy

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:YOUR_USERNAME/YOUR_REPO:ref:refs/*"
                }
            }
        }
    ]
}
```

- `sts:AssumeRoleWithWebIdentity` issues temporary credentials for federated users
- StringEquals for `aud`: ensures the token was issued for AWS STS (prevents misuse).
- StringLike for `sub`: restricts which repository and ref can assume the role (specific branches and tags)

**OIDC Flow**

```md
GitHub Actions Workflow
  |
  | 1. GitHub issues a JWT for the workflow run
  v
---------------------------------------
| GitHub OIDC Provider                |
| token.actions.githubusercontent.com |
---------------------------------------
  |
  | 2. Workflow sends JWT to AWS STS
  v
--------------------------------------
| AWS STS: AssumeRoleWithWebIdentity |
| Trust policy validates JWT         |
--------------------------------------
  |
  | 3. STS returns temporary AWS credentials
  v
-----------------------------------
| IAM Role (permissions attached) |
| Example: deploy to S3, Lambda   |
-----------------------------------
  |
  | 4. GitHub Actions uses credentials
  v
AWS Services (S3, Lambda, etc.)
```

1. **Workflow runs** in GitHub Actions.
2. **GitHub OIDC issues a JWT** scoped to that workflow run (requires `permissions: id-token: write`).
3. **Workflow sends JWT to AWS STS** via `AssumeRoleWithWebIdentity`.
4. **AWS STS validates the token** against the IAM role trust policy (checks `Principal`, `aud`, `sub`).
5. **STS returns temporary credentials** (access key, secret key, session token).
6. **Workflow uses these credentials** to securely call AWS services (S3, Lambda, etc.) without storing secrets in GitHub.

#### 3. GitHub Repository Configuration

Go to your `repo: Settings: Secrets and Variables: Actions:`

```md
Variables:
- AWS_ACCOUNT_ID: your-aws-account-id
- S3_BUCKET_NAME: your-unique-bucket-name
- REGION: ap-southeast-1
- LAMBDA_NAME: telegram-bot-function

Secrets:
- TELEGRAM_BOT_TOKEN: your_bot_token_from_botfather
```

**Why Variables vs Secrets?**

- **Variables:** Non-sensitive configuration (bucket names, regions)
- **Secrets:** Sensitive data (API keys, passwords) - encrypted by GitHub

### Exercise 3: Terraform Deep Dive

**Understanding Modules:**

Terraform modules are like functions - reusable pieces of infrastructure:

```hcl
# terraform/modules/lambda/main.tf
resource "aws_lambda_function" "this" {
  filename         = var.filename
  function_name    = var.function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "app.lambda_handler"
  runtime         = "python3.9"
}
```

### Exercise 4: Application Deployments

#### S3 Static Website Deployment

**What it does:** Automatically deploys static web content to S3 when `index.html` changes.

**Trigger:** Push to main branch with changes to `index.html`

**Key workflow steps:**

```yaml
# .github/workflows/deploy-s3.yml
on:
  push:
    branches: [main]
    paths: ['index.html']

steps:
  - name: Upload index.html to S3
    run: |
      aws s3 cp index.html s3://${{ vars.S3_BUCKET_NAME }}/index.html --content-type text/html
```

#### Lambda Function Deployment

**What it does:** Packages Python code with dependencies and updates Lambda function.

**Trigger:** Push to main branch with changes in `lambda/` directory

**Key workflow steps:**

```yaml
# .github/workflows/deploy-lambda.yml
steps:
  - name: Create Deployment Package
    run: |
      pip install -r requirements.txt -t ./package
      cp app.py ./package/
      cd package
      zip -r ../lambda-deployment.zip .

  - name: Deploy to AWS Lambda
    run: |
      aws lambda update-function-code \
        --function-name ${{ vars.LAMBDA_NAME }} \
        --zip-file fileb://lambda/lambda-deployment.zip
```

**Lambda Function Overview:**

- **Purpose:** Telegram bot that responds to `/start` and `/about` commands
- **Runtime:** Python 3.11
- **Dependencies:** `requests`, `boto3`
- **Secrets:** Bot token stored in AWS Secrets Manager

#### Packer AMI Building

**What it does:** Creates custom AMIs with pre-installed applications and configurations.

**Trigger:** Push to main branch with changes in `packer/` directory

**Key components:**

```hcl
# packer/builds/web-app/build.pkr.hcl
source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_name}-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.region
}

build {
  provisioner "shell" {
    script = "./scripts/setup.sh"
  }
  
  provisioner "file" {
    source      = "./app"
    destination = "/home/ubuntu/app"
  }
}
```

**What the AMI includes:**

- Ubuntu 22.04 base image
- Node.js application with dependencies
- Systemd service configuration
- CloudWatch Agent for monitoring
- Security hardening

### Exercise 5: Monitoring Your Deployment

**GitHub Actions Monitoring:**

- Go to Actions tab in your repository
- Watch real-time deployment logs
- Understand success/failure indicators

**AWS Monitoring:**

- CloudWatch Logs for Lambda function
- API Gateway metrics
- S3 bucket access logs

## Troubleshooting Common Issues

### Terraform State Conflicts

**Problem:** S3 bucket does not exist for backend

**Solution:** Manually create the s3 bucket you have specified in `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-name"
    key    = "git-demo/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
```

### GitHub Actions Permission Errors

**Problem:** `Error: Could not assume role`

**Solution:** Verify IAM role trust policy includes GitHub OIDC provider, and check if aud and sub are correct.

## Terraform Environment Management

There are a few ways to manage environments. Each method has its own use cases.

| Method | Code Location | Isolation | Duplication | Testing & Promotion | Pros | Cons | Use Case |
|--------|---------------|-----------|-------------|---------------------|------|------|----------|
| **A. Branch per environment** | Separate Git branch per environment (`dev`, `stag`, `prod`) | High — each environment is isolated | High — each branch may duplicate code | Natural promotion via PR merges (dev → staging → prod) | Clear promotion path, strong isolation, audit trail | Code duplication, maintenance overhead across branches | Small teams needing strong isolation and clear promotion path |
| **B. Folder per environment (single branch)** | One branch, separate folders (`envs/dev`, `envs/stag`, `envs/prod`) | Medium — isolated via folders | Medium — shared modules reduce duplication | Manual or CI/CD-based deployment per folder | Single source of truth for shared modules, easier refactoring | Branching/deployment logic can be complex, accidental deploy risk | Teams with a single branch CI/CD and multiple isolated environments |
| **C. Single branch, workspaces / tfvars** | One branch, shared code, different workspaces or `tfvars` per env | Low — isolation relies on workspaces or `tfvars` discipline | Low — minimal duplication | Manual or pipeline deployment per workspace; dev changes may affect staging/prod | Minimal duplication, easy to maintain shared logic, clean branching | Mistakes in workspace selection or tfvars can affect multiple envs, dev changes may break staging/prod | Larger teams/projects wanting minimal duplication and workspace-based environment management |

### **A. One branch per environment**

**Description:**

- Each environment (dev, staging, prod) has its own Git branch.
- Terraform code may be duplicated or partially shared.

**Structure Example:**

```md
Branches:
┌─────────-┐        ┌───────────┐        ┌───────────┐
| dev      |        | stag      |        | prod      |
|----------|        |-----------|        |-----------|
| main.tf  |        | main.tf   |        | main.tf   |
| vars.tf  |        | vars.tf   |        | vars.tf   |
| modules/ |        | modules/  |        | modules/  |
└──────────┘        └───────────┘        └───────────┘
```

**Pros:**

- Easy to isolate changes per environment.
- No risk of accidentally applying dev changes to prod.

**Cons:**

- Duplication of code between branches (each has its own modules/); very difficult to update the modules.

**Use case:**

- If require clear segregation between envs.
- For teams familiar with having 1 env per branch.

### **B. One folder per environment (single branch)**

**Description:**

- All environments live in the same branch.
- Each environment has its own folder and `terraform.tfvars`.
- Shared modules/

**Structure Example:**

```md
repo/
├─ envs/
│  ├─ dev/
│  │  └─ main.tf
│  ├─ stag/
│  │  └─ main.tf
│  └─ prod/
│     └─ main.tf
├─ modules/
```

**Pros:**

- Single source of truth for shared modules.
- Easier to refactor common code.

**Cons:**

- Branching/deployment logic can get more complex (we use specific regex tagged deployments to overcome this).

**Use case:**

- If large % of codebase are shared modules, but still want retain flexibility of deploying infra in each env.
- Medium-sized companies with dedicated team to manage common modules.

### **C. Single branch, workspaces or variables**

**Description:**

- Single Terraform configuration per module.
- Use **Terraform workspaces** or environment-specific `tfvars` files.

**Structure Example:**

```md
repo/
├─ main.tf
├─ variables.tf
├─ dev.tfvars
├─ stag.tfvars
└─ prod.tfvars
└─ modules/
```

**Usage:**

```bash
terraform workspace select dev
terraform apply -var-file=dev.tfvars
```

**Pros:**

- Minimal duplication.

**Cons:**

- Fully shared IaC, only differentiated by env variables.
- No branch promotion like in A.
- Testing a new feature in dev immediately changes the code that staging/prod will eventually use.

**Use case:**

- If all envs will have exact same infrastructure.
- Small team just starting out; simple infra, no need much isolation between envs.

## Monitoring and Alerting

- CloudWatch alarms for Lambda errors
- SNS notifications for deployment failures
- Application Performance Monitoring (APM)

## Additional Resources

- [Terraform Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Git Flow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)

---

## Testing Your Deployments

### S3 Website

```sh
# Make a change to index.html
echo "<h1>Updated content</h1>" >> index.html
git add index.html
git commit -m "feat: update website content"
git push origin main
```

### Lambda Function

```sh
# Modify lambda/app.py
# Add a new command or change response text
git add lambda/
git commit -m "feat: add new bot command"
git push origin main
```

### Packer AMI

```sh
# Update packer configuration or app
git add packer/
git commit -m "feat: update AMI configuration"
git push origin main
```

**Remember:** The goal isn't just to make it work, but to understand *why* it works and how it applies to real-world team development. Take time to experiment and break things - that's how you learn!
