# CI/CD Pipeline Documentation

## Overview

This project uses **GitHub Actions** for continuous integration and continuous deployment (CI/CD). Every push to the `main` branch automatically deploys infrastructure changes to AWS.

---

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Push to Main                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Job 1: Validate & Test                         │
│  • Python syntax check (Lambda function)                    │
│  • Terraform format check                                   │
│  • Terraform validate                                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Job 2: Terraform Plan (PR only)                │
│  • Preview infrastructure changes                           │
│  • Show what will be created/modified/destroyed             │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Job 3: Deploy to AWS                           │
│  • Terraform init                                           │
│  • Terraform plan (save to file)                            │
│  • Terraform apply (auto-approve)                           │
│  • CloudFront cache invalidation                            │
│  • Output website & API URLs                                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Job 4: Test Deployment                         │
│  • Test API Gateway endpoint (HTTP 200 + JSON)              │
│  • Test website availability (HTTP 200)                     │
│  • Display deployment summary                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Workflow File

**Location:** `.github/workflows/front-end-cicd.yml`

### Triggers

```yaml
on:
  push:
    branches:
      - main          # Auto-deploy on push to main
  pull_request:
    branches:
      - main          # Run validation on PRs
```

---

## Jobs Breakdown

### Job 1: Validate & Test

**Purpose:** Ensure code quality before deployment

**Steps:**
1. **Checkout Code** - Get latest code from repository
2. **Setup Python** - Install Python 3.9
3. **Install Dependencies** - boto3, pytest
4. **Validate Lambda Syntax** - Check Python syntax
5. **Setup Terraform** - Install Terraform 1.5.0
6. **Terraform Format Check** - Ensure consistent formatting
7. **Terraform Validate** - Validate Terraform configuration

**Duration:** ~1-2 minutes

---

### Job 2: Terraform Plan (Pull Requests Only)

**Purpose:** Preview changes before merging

**Steps:**
1. **Checkout Code**
2. **Setup Terraform**
3. **Configure AWS Credentials**
4. **Terraform Init**
5. **Terraform Plan** - Show what will change

**When:** Only runs on Pull Requests

**Duration:** ~1-2 minutes

---

### Job 3: Deploy to AWS

**Purpose:** Deploy infrastructure to AWS

**Steps:**
1. **Checkout Code**
2. **Setup Terraform**
3. **Configure AWS Credentials** - Use GitHub Secrets
4. **Terraform Init** - Initialize backend & providers
5. **Terraform Plan** - Create execution plan
6. **Terraform Apply** - Apply changes to AWS
7. **Get CloudFront ID** - Extract from Terraform output
8. **Invalidate CloudFront** - Clear CDN cache
9. **Get URLs** - Display website & API URLs

**When:** Only on push to `main` branch

**Duration:** ~2-4 minutes

---

### Job 4: Test Deployment

**Purpose:** Verify deployment success

**Steps:**
1. **Checkout Code**
2. **Setup Terraform**
3. **Configure AWS Credentials**
4. **Terraform Init**
5. **Test API Gateway** - curl endpoint, check HTTP 200 & JSON
6. **Test Website** - curl website, check HTTP 200
7. **Deployment Summary** - Display URLs and status

**When:** Only after successful deployment

**Duration:** ~1 minute

---

## GitHub Secrets Required

The pipeline requires these secrets to be configured in GitHub:

### AWS Credentials

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `AWS_ACCESS_KEY_ID` | AWS access key | IAM User → Security Credentials |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | IAM User → Security Credentials |

### How to Add Secrets

1. Go to GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add both secrets

**Security Note:** Never commit AWS credentials to code!

---

## Workflow Execution

### Successful Deployment

```
✅ Validate & Test (1m 30s)
  ✅ Lambda syntax valid
  ✅ Terraform format OK
  ✅ Terraform validate passed

✅ Deploy to AWS (3m 15s)
  ✅ Terraform init
  ✅ Terraform plan created
  ✅ Terraform apply successful
  ✅ CloudFront invalidation initiated
  🌐 Website: https://d150bm922en909.cloudfront.net
  🚀 API Gateway: https://xxx.execute-api.us-east-1.amazonaws.com/prod/count

✅ Test Deployment (45s)
  ✅ API Gateway test passed (HTTP 200)
  ✅ Website test passed (HTTP 200)
  🎉 Deployment Successful!
```

**Total Time:** ~5-6 minutes

---

### Failed Deployment

If any step fails, the pipeline stops and sends notification:

```
❌ Validate & Test (30s)
  ❌ Lambda syntax error: SyntaxError line 15
  
Pipeline stopped. Fix errors and push again.
```

---

## Testing Strategy

### 1. Syntax Validation

```bash
python -m py_compile lambda/func.py
```

Checks Python syntax before deployment.

### 2. Terraform Validation

```bash
terraform validate
```

Validates Terraform configuration syntax.

### 3. API Gateway Test

```bash
curl https://api-gateway-url/prod/count
```

**Checks:**
- HTTP status code = 200
- Response contains "count" field
- Valid JSON format

### 4. Website Test

```bash
curl https://cloudfront-url
```

**Checks:**
- HTTP status code = 200
- Website is accessible

---

## Deployment Frequency

| Event | Frequency | Auto-Deploy |
|-------|-----------|-------------|
| Push to `main` | Every commit | ✅ Yes |
| Pull Request | Every PR | ❌ No (plan only) |
| Manual | On-demand | ✅ Yes (via GitHub UI) |

---

## Rollback Strategy

### Automatic Rollback

Pipeline does NOT auto-rollback. If deployment fails:
1. Fix the issue in code
2. Push new commit
3. Pipeline will deploy the fix

### Manual Rollback

```bash
# Revert to previous commit
git revert HEAD
git push origin main

# Or checkout previous commit
git checkout <previous-commit-hash>
git push origin main --force
```

---

## Monitoring

### GitHub Actions UI

View pipeline status:
- Repository → Actions tab
- See all workflow runs
- Click on run for detailed logs

### Status Badge

README shows pipeline status:

![GitHub Actions](https://github.com/yusdar31/cloud-resume-aws/workflows/Deploy%20Cloud%20Resume%20to%20AWS/badge.svg)

- ✅ Green = Passing
- ❌ Red = Failing
- ⚪ Gray = Pending

---

## Cost

**GitHub Actions Free Tier:**
- 2,000 minutes/month for public repositories
- Unlimited for public repos

**This pipeline uses:** ~5-6 minutes per deployment

**Monthly cost:** $0 (well within free tier)

---

## Best Practices

### 1. Always Create Pull Requests

```bash
git checkout -b feature/new-feature
# Make changes
git commit -m "Add new feature"
git push origin feature/new-feature
# Create PR on GitHub
```

**Benefits:**
- See Terraform plan before merge
- Code review opportunity
- Safer deployments

### 2. Use Descriptive Commit Messages

```bash
# Good
git commit -m "feat: Add custom domain support"
git commit -m "fix: Resolve CORS issue in Lambda"

# Bad
git commit -m "update"
git commit -m "fix bug"
```

### 3. Test Locally First

```bash
# Validate Terraform
terraform validate

# Check Python syntax
python -m py_compile lambda/func.py

# Format Terraform
terraform fmt -recursive
```

---

## Troubleshooting

### Pipeline Fails on Terraform Init

**Error:** `Error: Failed to get existing workspaces`

**Solution:** Check AWS credentials in GitHub Secrets

---

### Pipeline Fails on Terraform Apply

**Error:** `Error: creating S3 Bucket: BucketAlreadyExists`

**Solution:** S3 bucket names must be globally unique. Change bucket name in `main.tf`

---

### CloudFront Invalidation Fails

**Error:** `An error occurred (NoSuchDistribution)`

**Solution:** Ensure CloudFront distribution exists. Run `terraform apply` manually first.

---

### API Gateway Test Fails

**Error:** `❌ API Gateway test failed! HTTP 403`

**Solution:** 
1. Check Lambda function permissions
2. Verify API Gateway configuration
3. Check CORS settings

---

## Future Enhancements

### Planned Improvements

- [ ] **Slack Notifications** - Send deployment status to Slack
- [ ] **Multi-Environment** - Dev, staging, prod environments
- [ ] **Terraform Cloud** - Remote state management
- [ ] **Unit Tests** - Pytest for Lambda function
- [ ] **Integration Tests** - End-to-end testing
- [ ] **Performance Tests** - Load testing with k6
- [ ] **Security Scanning** - tfsec, checkov
- [ ] **Cost Estimation** - Infracost integration

---

## Manual Deployment (Backup)

If GitHub Actions is down, deploy manually:

```bash
# 1. Configure AWS credentials
aws configure

# 2. Initialize Terraform
terraform init

# 3. Plan changes
terraform plan

# 4. Apply changes
terraform apply

# 5. Invalidate CloudFront
DIST_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"
```

---

## Conclusion

This CI/CD pipeline provides:
- ✅ Automated deployments
- ✅ Quality checks before deployment
- ✅ Automated testing after deployment
- ✅ Fast feedback loop (~5-6 minutes)
- ✅ Zero cost (GitHub Actions free tier)

**Result:** Professional DevOps workflow that impresses recruiters! 🚀

---

*Last updated: February 2026*
