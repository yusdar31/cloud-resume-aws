# Cost Analysis

## Monthly Cost Breakdown

### Within AWS Free Tier (First 12 Months)

| Service | Free Tier Allowance | Estimated Usage | Cost |
|---------|-------------------|-----------------|------|
| **Amazon S3** | 5 GB storage<br/>20,000 GET requests<br/>2,000 PUT requests | 1 MB storage<br/>100 GET requests<br/>10 PUT requests | **$0.00** |
| **Amazon CloudFront** | 1 TB data transfer out<br/>10,000,000 HTTP/HTTPS requests | 1 GB transfer<br/>500 requests | **$0.00** |
| **AWS Lambda** | 1,000,000 requests/month<br/>400,000 GB-seconds compute | 500 requests<br/>64 GB-seconds | **$0.00** |
| **Amazon API Gateway** | 1,000,000 API calls/month | 500 calls | **$0.00** |
| **Amazon DynamoDB** | 25 GB storage<br/>25 WCU<br/>25 RCU | 1 KB storage<br/>0.01 WCU<br/>0.01 RCU | **$0.00** |
| **Amazon CloudWatch** | 5 GB log ingestion<br/>5 GB log storage | 10 MB logs | **$0.00** |
| **TOTAL** | | | **$0.00/month** |

---

### After Free Tier (Month 13+)

| Service | Pricing | Estimated Usage | Monthly Cost |
|---------|---------|-----------------|--------------|
| **Amazon S3** | $0.023/GB storage<br/>$0.0004/1K GET | 1 MB<br/>100 GET | **$0.00** |
| **Amazon CloudFront** | $0.085/GB (first 10TB)<br/>$0.0075/10K requests | 1 GB<br/>500 requests | **$0.09** |
| **AWS Lambda** | $0.20/1M requests<br/>$0.0000166667/GB-second | 500 requests<br/>64 GB-seconds | **$0.00** |
| **Amazon API Gateway** | $3.50/1M requests | 500 requests | **$0.00** |
| **Amazon DynamoDB** | $0.25/GB storage<br/>$1.25/1M write requests | 1 KB<br/>500 writes | **$0.00** |
| **Amazon CloudWatch** | $0.50/GB ingestion<br/>$0.03/GB storage | 10 MB | **$0.00** |
| **TOTAL** | | | **~$0.09/month** |

---

## Traffic Scenarios

### Scenario 1: Low Traffic (Current)
**Assumptions:**
- 100 visitors/month
- Average 1 page view per visitor
- 1 API call per visitor

**Monthly Cost:** $0.00 (within free tier) or $0.09 (after free tier)

---

### Scenario 2: Medium Traffic
**Assumptions:**
- 10,000 visitors/month
- Average 2 page views per visitor
- 1 API call per visitor

| Service | Usage | Cost (After Free Tier) |
|---------|-------|----------------------|
| CloudFront | 100 GB transfer, 20K requests | $8.65 |
| S3 | 1 MB, 20K GET | $0.01 |
| Lambda | 10K invocations | $0.00 |
| API Gateway | 10K calls | $0.04 |
| DynamoDB | 10K writes | $0.01 |
| **TOTAL** | | **~$8.71/month** |

---

### Scenario 3: High Traffic
**Assumptions:**
- 100,000 visitors/month
- Average 3 page views per visitor
- 1 API call per visitor

| Service | Usage | Cost (After Free Tier) |
|---------|-------|----------------------|
| CloudFront | 1 TB transfer, 300K requests | $87.25 |
| S3 | 10 MB, 300K GET | $0.12 |
| Lambda | 100K invocations | $0.02 |
| API Gateway | 100K calls | $0.35 |
| DynamoDB | 100K writes | $0.13 |
| **TOTAL** | | **~$87.87/month** |

---

## Cost Optimization Strategies

### 1. CloudFront Caching ✅ Implemented
- **Impact:** Reduces S3 requests by 90%+
- **Savings:** ~$0.01/month (current traffic)
- **Configuration:** 24-hour cache TTL

### 2. DynamoDB On-Demand ✅ Implemented
- **Impact:** Pay only for actual usage
- **Savings:** ~$5/month vs provisioned capacity
- **Best for:** Unpredictable traffic patterns

### 3. Lambda Right-Sizing ✅ Implemented
- **Impact:** Minimize compute costs
- **Savings:** ~$0.01/month
- **Configuration:** 128MB memory (minimum needed)

### 4. S3 Lifecycle Policies ⏳ Future
- **Impact:** Archive old logs to Glacier
- **Savings:** ~$0.01/month
- **Configuration:** Move logs >90 days to Glacier

### 5. CloudWatch Log Retention ⏳ Future
- **Impact:** Reduce log storage costs
- **Savings:** ~$0.01/month
- **Configuration:** 30-day retention for Lambda logs

### 6. Reserved Capacity ❌ Not Recommended
- **Impact:** Lower per-request costs
- **Savings:** Minimal for low traffic
- **Reason:** On-demand better for variable traffic

---

## Cost Comparison: Alternatives

### vs Traditional Hosting

| Solution | Monthly Cost | Scalability | Maintenance |
|----------|-------------|-------------|-------------|
| **AWS Serverless** | $0.00 - $0.09 | Automatic | Minimal |
| **Shared Hosting** | $5 - $15 | Limited | Manual |
| **VPS** | $10 - $50 | Manual | High |
| **Dedicated Server** | $100+ | Manual | Very High |

**Winner:** AWS Serverless (cost + scalability + low maintenance)

---

### vs Other Cloud Providers

| Provider | Equivalent Services | Est. Cost |
|----------|-------------------|-----------|
| **AWS** | S3 + CloudFront + Lambda + API GW + DynamoDB | $0.00 - $0.09 |
| **Google Cloud** | Cloud Storage + CDN + Cloud Functions + Firestore | $0.00 - $0.15 |
| **Azure** | Blob Storage + CDN + Functions + Cosmos DB | $0.00 - $0.20 |
| **Vercel** | Hosting + Serverless Functions | $0.00 (hobby) |
| **Netlify** | Hosting + Functions | $0.00 (starter) |

**Note:** AWS provides most comprehensive free tier and best learning opportunity for cloud skills.

---

## Cost Monitoring

### AWS Cost Explorer
- View daily/monthly costs
- Filter by service
- Forecast future costs

### AWS Budgets
- Set budget alerts
- Get notified at 80% threshold
- Prevent unexpected charges

### Recommended Budget Alert:
```
Budget: $1.00/month
Alert at: 80% ($0.80)
Notification: Email
```

---

## Total Cost of Ownership (TCO)

### One-Time Costs:
- Domain name: $12/year (optional)
- SSL certificate: $0 (ACM is free)
- Development time: N/A (learning project)

### Recurring Costs:
- AWS services: $0.00 - $0.09/month
- Domain renewal: $12/year (optional)

### Annual TCO:
- **With free tier:** $0 - $12/year (domain only)
- **After free tier:** $1.08 - $13.08/year

---

## ROI Analysis

### Investment:
- Time: ~10-15 hours (learning + development)
- Money: $0 - $12/year

### Returns:
- ✅ AWS hands-on experience
- ✅ Portfolio project for job applications
- ✅ Terraform/IaC skills
- ✅ Serverless architecture knowledge
- ✅ Potential salary increase from cloud skills

**Estimated value:** $5,000 - $20,000 salary increase with AWS skills

**ROI:** Infinite (minimal cost, high value)

---

## Cost Alerts Configuration

### Terraform Code (Future):
```hcl
resource "aws_budgets_budget" "monthly" {
  name         = "cloud-resume-monthly-budget"
  budget_type  = "COST"
  limit_amount = "1"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 80
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"
    
    subscriber_email_addresses = ["your.email@example.com"]
  }
}
```

---

## Conclusion

**Current Cost:** $0.00/month (within free tier)

**After Free Tier:** ~$0.09/month (negligible)

**Scalability:** Can handle 10,000+ visitors/month for < $10/month

**Recommendation:** This architecture is extremely cost-effective for a resume website and provides excellent value for learning AWS services.

---

*Last updated: February 2026*
