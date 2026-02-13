# Cloud Resume Challenge - AWS Edition ☁️

![AWS Cloud Resume Challenge](https://img.shields.io/badge/AWS-Cloud_Resume_Challenge-232f3e?style=for-the-badge&logo=amazon-aws)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7b42bc?style=for-the-badge&logo=terraform)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088ff?style=for-the-badge&logo=github-actions)

This repository contains the source code and infrastructure for my **Cloud Resume Challenge**. It showcases a serverless resume website deployed on AWS, built with Infrastructure as Code (IaC) and automated CI/CD pipelines.

**Live Demo:** [Check out my Cloud Resume]([https://d150bm922en909.cloudfront.net](https://www.andiyusdaralimran.my.id/))

## 🚀 Features

- **Serverless Architecture**: Hosted on S3 + CloudFront, with backend logic on Lambda + DynamoDB.
- **Infrastructure as Code**: 100% of AWS resources provisioned via **Terraform**.
- **CI/CD Pipeline**: Automated testing and deployment using **GitHub Actions**.
- **Visitor Counter**: Real-time page view tracking using DynamoDB and API Gateway.
- **Modern UI/UX**:
  - **Premium Dark Theme** design.
  - **Glassmorphism** styling with Tailwind CSS.
  - Fully responsive and mobile-friendly.
- **Static Blog System**: Integrated JSON-based blog for sharing technical insights.
- **Containerized Development**: Local development environment supported via **Docker Compose**.

## 🛠️ Tech Stack

### Frontend
- **HTML5 & CSS3**
- **Tailwind CSS** (Styling)
- **Vanilla JavaScript** (Logic & API Integration)
- **Lucide Icons**

### Backend & Database
- **AWS Lambda** (Python/Boto3)
- **Amazon DynamoDB** (NoSQL Database)
- **Amazon API Gateway** (REST API)

### Infrastructure & DevOps
- **Terraform** (IaC for S3, CloudFront, ACM, Route53, Lambda, DynamoDB)
- **GitHub Actions** (CI/CD for frontend & terraform)
- **AWS CloudFront** (CDN & HTTPS)
- **AWS S3** (Static Website Hosting)
- **Docker & Docker Compose** (Containerization)

## 📂 Project Structure

```bash
.
├── websites/               # Frontend source code
│   ├── assets/             # Images and logos
│   ├── blog-posts/         # Individual blog page templates
│   ├── blogs.json          # Blog metadata
│   ├── index.html          # Main resume page
│   └── styles.css          # Custom styles
├── main.tf                 # Terraform configuration (Resources)
├── outputs.tf              # Terraform outputs
├── variables.tf            # Terraform variables
├── lambda/                 # Python backend code
└── .github/workflows/      # CI/CD pipelines
```

## 🔧 Setup & Deployment

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/yourusername/cloud-resume-challange.git
    cd cloud-resume-challange
    ```

2.  **Infrastructure Deployment (Terraform)**
    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

3.  **Frontend Deployment**
    The frontend is automatically deployed via GitHub Actions on push to `main`.
    
    *Manual upload:*
    ```bash
    aws s3 sync ./websites s3://your-bucket-name
    ```
4.  **🐳 Running with Docker (Local Development)**

    You can run the website locally using Docker Compose:

    ```bash
    docker-compose up -d --build
    ```
    
    Access the site at **http://localhost:8080**.

## 📈 Architecture

The architecture follows the **Cloud Resume Challenge** requirements:
1.  **S3** stores the HTML/CSS/JS.
2.  **CloudFront** serves the content via HTTPS.
3.  **Javascript** fetches the visitor count.
4.  **API Gateway** triggers the Lambda function.
5.  **Lambda** updates and retrieves the count from **DynamoDB**.

---

## 👤 Author

**Andi Yusdar Al Imran**
- [LinkedIn](https://linkedin.com/in/andiyusdar)
- [GitHub](https://github.com/yusdar31)

---
*Built as part of the Cloud Resume Challenge.*
