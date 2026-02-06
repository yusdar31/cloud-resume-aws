# Architecture Documentation

## System Architecture Overview

This document provides detailed technical documentation of the AWS Cloud Resume architecture.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER BROWSER                             │
│                    (Global - Any Location)                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTPS Request
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CLOUDFRONT DISTRIBUTION                       │
│                  (Edge Locations Worldwide)                      │
│  • HTTPS Only                                                    │
│  • Cache TTL: 86400s                                            │
│  • Origin Access Control (OAC)                                  │
└────────────┬────────────────────────────┬───────────────────────┘
             │                            │
             │ Static Content             │ API Calls
             ▼                            ▼
┌─────────────────────────┐  ┌──────────────────────────────────┐
│      S3 BUCKET          │  │       API GATEWAY                │
│  (Static Website)       │  │    (REST API - Regional)         │
│                         │  │                                  │
│  • index.html           │  │  • Endpoint: /prod/count        │
│  • CSS/JS Assets        │  │  • Method: GET                  │
│  • Public Read (OAC)    │  │  • CORS Enabled                 │
└─────────────────────────┘  └────────────┬─────────────────────┘
                                          │
                                          │ Invoke
                                          ▼
                             ┌──────────────────────────────────┐
                             │      LAMBDA FUNCTION             │
                             │   (visitor_counter_func)         │
                             │                                  │
                             │  • Runtime: Python 3.9          │
                             │  • Memory: 128 MB               │
                             │  • Timeout: 3s                  │
                             │  • Handler: func.handler        │
                             └────────────┬─────────────────────┘
                                          │
                                          │ UpdateItem (Atomic)
                                          ▼
                             ┌──────────────────────────────────┐
                             │        DYNAMODB TABLE            │
                             │   (CloudResume-VisitorCount)     │
                             │                                  │
                             │  • Partition Key: id (String)   │
                             │  • Attribute: count (Number)    │
                             │  • Billing: On-Demand           │
                             └──────────────────────────────────┘
```

## Component Details

### 1. CloudFront Distribution

**Purpose:** Global CDN for fast content delivery

**Configuration:**
- **Origin:** S3 bucket (static website)
- **Protocol:** HTTPS only (redirect HTTP to HTTPS)
- **Caching:** Default cache behavior (24 hours)
- **Security:** Origin Access Control (OAC) for S3
- **Compression:** Enabled (gzip, brotli)

**Benefits:**
- Low latency worldwide
- DDoS protection
- SSL/TLS termination
- Reduced S3 costs

---

### 2. S3 Bucket

**Purpose:** Static website hosting

**Configuration:**
- **Access:** Private (only CloudFront via OAC)
- **Versioning:** Disabled
- **Encryption:** Server-side (AES-256)
- **Content:** HTML, CSS, JavaScript

**Files:**
- `index.html` - Main resume page
- `simple-test.html` - API test page

---

### 3. API Gateway

**Purpose:** RESTful API endpoint for visitor counter

**Configuration:**
- **Type:** REST API (Regional)
- **Endpoint:** `/prod/count`
- **Methods:** GET, OPTIONS (CORS)
- **Authorization:** None (public)
- **Integration:** Lambda (AWS_PROXY)

**CORS Configuration:**
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Headers: Content-Type
Access-Control-Allow-Methods: GET, POST, OPTIONS
```

---

### 4. Lambda Function

**Purpose:** Serverless compute for visitor counter logic

**Configuration:**
- **Runtime:** Python 3.9
- **Memory:** 128 MB
- **Timeout:** 3 seconds
- **Handler:** func.handler
- **Environment Variables:**
  - `TABLE_NAME`: CloudResume-VisitorCount

**Code Logic:**
```python
1. Receive API Gateway event
2. Update DynamoDB item (atomic increment)
3. Return updated count with CORS headers
```

**IAM Permissions:**
- `dynamodb:UpdateItem`
- `dynamodb:GetItem`
- `logs:CreateLogGroup`
- `logs:CreateLogStream`
- `logs:PutLogEvents`

---

### 5. DynamoDB Table

**Purpose:** Persistent storage for visitor count

**Configuration:**
- **Table Name:** CloudResume-VisitorCount
- **Partition Key:** id (String)
- **Billing Mode:** On-Demand
- **Attributes:**
  - `id`: "visitor_count" (Primary Key)
  - `count`: Number (incremented atomically)

**Why DynamoDB:**
- Serverless (no provisioning)
- Atomic operations (no race conditions)
- Low latency
- Free tier: 25 GB storage

---

### 6. CloudWatch

**Purpose:** Logging and monitoring

**Log Groups:**
- `/aws/lambda/visitor_counter_func` - Lambda execution logs
- API Gateway access logs (optional)

**Metrics:**
- Lambda invocations
- Lambda errors
- Lambda duration
- API Gateway requests
- API Gateway 4xx/5xx errors

---

## Data Flow

### Visitor Counter Flow:

```
1. User opens website
   └─> CloudFront serves index.html from S3

2. JavaScript executes
   └─> fetch('https://api-gateway-url/prod/count')

3. API Gateway receives request
   └─> Validates CORS headers
   └─> Invokes Lambda function

4. Lambda function executes
   └─> Connects to DynamoDB
   └─> Executes UpdateItem with ADD operation
   └─> Retrieves updated count

5. Lambda returns response
   └─> Status: 200
   └─> Body: {"count": 42}
   └─> Headers: CORS headers

6. API Gateway forwards response
   └─> Adds API Gateway headers
   └─> Returns to browser

7. JavaScript updates DOM
   └─> document.getElementById('counter').innerText = data.count
```

---

## Security Architecture

### 1. S3 Bucket Security
- ✅ Private bucket (no public access)
- ✅ Access only via CloudFront OAC
- ✅ Server-side encryption (SSE-S3)
- ✅ Bucket policy restricts to CloudFront

### 2. API Security
- ✅ HTTPS only (TLS 1.2+)
- ✅ CORS properly configured
- ✅ No sensitive data in responses
- ⚠️ No authentication (public API)
- ⚠️ No rate limiting (future improvement)

### 3. Lambda Security
- ✅ Least privilege IAM role
- ✅ No hardcoded credentials
- ✅ Environment variables for config
- ✅ CloudWatch logging enabled

### 4. DynamoDB Security
- ✅ Encryption at rest (AWS managed)
- ✅ Encryption in transit (HTTPS)
- ✅ IAM-based access control
- ✅ No public access

---

## Scalability

### Current Limits:

| Component | Limit | Notes |
|-----------|-------|-------|
| CloudFront | Unlimited | Global CDN |
| S3 | 5,500 GET/s per prefix | More than enough |
| API Gateway | 10,000 RPS (regional) | Can request increase |
| Lambda | 1,000 concurrent | Can request increase |
| DynamoDB | 40,000 RCU/WCU | On-demand auto-scales |

**Bottleneck:** None for typical resume website traffic (100-1000 visitors/day)

**Can handle:** 10,000+ concurrent users without issues

---

## High Availability

### Redundancy:

- **CloudFront:** Multi-region edge locations
- **S3:** 99.999999999% durability (11 9's)
- **API Gateway:** Multi-AZ by default
- **Lambda:** Multi-AZ by default
- **DynamoDB:** Multi-AZ replication

**SLA:**
- CloudFront: 99.9%
- S3: 99.9%
- API Gateway: 99.95%
- Lambda: 99.95%
- DynamoDB: 99.99%

**Combined availability:** ~99.7% (very high!)

---

## Disaster Recovery

### Backup Strategy:

1. **Code:** Version controlled in Git
2. **Infrastructure:** Defined in Terraform (reproducible)
3. **DynamoDB:** Point-in-time recovery (optional)
4. **S3:** Versioning (optional)

### Recovery Time:

- **Infrastructure:** ~5 minutes (terraform apply)
- **Data:** DynamoDB data can be backed up
- **RTO:** < 10 minutes
- **RPO:** < 1 hour (with backups)

---

## Monitoring Strategy

### Key Metrics to Monitor:

1. **Lambda:**
   - Invocation count
   - Error rate
   - Duration
   - Throttles

2. **API Gateway:**
   - Request count
   - 4xx errors (client errors)
   - 5xx errors (server errors)
   - Latency

3. **DynamoDB:**
   - Read/write capacity
   - Throttled requests
   - System errors

4. **CloudFront:**
   - Cache hit ratio
   - 4xx/5xx error rate
   - Bytes downloaded

### Recommended Alarms:

- Lambda error rate > 5%
- API Gateway 5xx errors > 1%
- DynamoDB throttled requests > 0
- CloudFront 5xx error rate > 1%

---

## Cost Optimization

### Current Optimizations:

1. **CloudFront caching** - Reduces S3 requests
2. **On-demand DynamoDB** - Pay only for usage
3. **Lambda right-sizing** - 128MB (minimum needed)
4. **S3 lifecycle policies** - (future: archive old logs)

### Cost Breakdown (After Free Tier):

```
CloudFront: $0.085/GB (first 10TB) × 1GB = $0.09
S3: $0.023/GB × 0.001GB = $0.00
Lambda: $0.20/1M requests × 500 = $0.00
API Gateway: $3.50/1M requests × 500 = $0.00
DynamoDB: $1.25/1M writes × 500 = $0.00

Total: ~$0.09/month
```

---

## Performance Optimization

### Current Optimizations:

1. **CloudFront caching** - 24 hour TTL
2. **Gzip compression** - Reduces transfer size
3. **Lambda memory** - 128MB (fast enough)
4. **DynamoDB on-demand** - No throttling

### Performance Metrics:

- **Page Load Time:** < 1 second (global)
- **API Response Time:** < 100ms
- **Lambda Cold Start:** < 500ms
- **Lambda Warm Start:** < 50ms

---

## Future Architecture Improvements

### Short Term:
1. Custom domain with Route 53
2. ACM certificate for HTTPS
3. WAF for security
4. API Gateway caching

### Long Term:
1. Multi-region deployment
2. DynamoDB global tables
3. Lambda@Edge for personalization
4. CloudWatch dashboards

---

*This architecture follows AWS Well-Architected Framework principles: Operational Excellence, Security, Reliability, Performance Efficiency, and Cost Optimization.*
