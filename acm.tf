# ACM Certificate untuk SSL/TLS
# PENTING: Certificate harus di us-east-1 untuk CloudFront
resource "aws_acm_certificate" "ssl_certificate" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "www.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "Cloud Resume Certificate"
    Environment = "Production"
  }
}

# Certificate Validation - menunggu sampai certificate tervalidasi
# CATATAN: Ini akan HANG sampai Anda menambahkan DNS records ke Rumahweb!
# Jika Anda belum siap validasi, comment out resource ini dulu
resource "aws_acm_certificate_validation" "ssl_validation" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.ssl_certificate.arn

  # Terraform akan menunggu sampai certificate tervalidasi via DNS
  # Timeout setelah 45 menit jika tidak tervalidasi
  timeouts {
    create = "45m"
  }
}

# Output untuk DNS validation records
# Anda perlu menambahkan CNAME records ini ke Rumahweb
output "certificate_validation_records" {
  description = "DNS records untuk validasi certificate - tambahkan ke Rumahweb DNS"
  value = {
    for dvo in aws_acm_certificate.ssl_certificate.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  sensitive = false
}

output "certificate_arn" {
  description = "ARN dari ACM certificate"
  value       = aws_acm_certificate.ssl_certificate.arn
}

output "certificate_status" {
  description = "Status dari ACM certificate"
  value       = aws_acm_certificate.ssl_certificate.status
}
