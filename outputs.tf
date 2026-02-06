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

output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/count"
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.resume_bucket.id
}
