output "website_url" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "api_endpoint" {
  value = aws_lambda_function_url.api_url.function_url
}

output "cloudfront_distribution_id" {
  description = "ID dari CloudFront Distribution"
  value       = aws_cloudfront_distribution.s3_distribution.id
}