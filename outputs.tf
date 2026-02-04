output "website_url" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "api_endpoint" {
  value = aws_lambda_function_url.api_url.function_url
}