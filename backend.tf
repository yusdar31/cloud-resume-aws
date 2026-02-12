# --- 1. DynamoDB (Database) ---
resource "aws_dynamodb_table" "visitor_table" {
  name         = "CloudResume-VisitorCount"
  billing_mode = "PAY_PER_REQUEST" # Hemat biaya (Serverless), bayar kalau ada yg akses aja
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S" # S = String
  }
}

# --- 2. Lambda Function (Compute) ---

# Bungkus file Python tadi jadi ZIP (Lambda butuh file .zip)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/func.py"
  output_path = "${path.module}/lambda/func.zip"
}

# IAM Role: Identitas untuk Lambda (agar punya izin akses AWS)
resource "aws_iam_role" "lambda_role" {
  name = "resume_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# IAM Policy: Izin spesifik agar Lambda BISA menulis ke DynamoDB
resource "aws_iam_role_policy" "lambda_policy" {
  name = "resume_lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Izin nulis log (penting buat debugging)
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        # Izin akses DynamoDB
        Action   = ["dynamodb:UpdateItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Scan", "dynamodb:Query"],
        Effect   = "Allow",
        Resource = [aws_dynamodb_table.visitor_table.arn, aws_dynamodb_table.blog_table.arn]
      }
    ]
  })
}

# Lambda Function itu sendiri
resource "aws_lambda_function" "visitor_counter" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "visitor_counter_func"
  role             = aws_iam_role.lambda_role.arn
  handler          = "func.handler" # NamaFile.NamaFungsi
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Kirim nama tabel ke Python lewat Environment Variable
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitor_table.name
    }
  }
}

# --- 3. Function URL (Cara Paling Simpel bikin API) ---
# Di SAA nanti kamu belajar API Gateway, tapi Function URL adalah fitur baru AWS 
# yang lebih simpel untuk kasus single function seperti ini.

resource "aws_lambda_function_url" "api_url" {
  function_name      = aws_lambda_function.visitor_counter.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST"]
    allow_headers     = ["*"]
    expose_headers    = ["*"]
    max_age           = 86400
  }
}

# 2. Izin Publik (Tanpa Syarat yang Aneh-aneh)
resource "aws_lambda_permission" "allow_public_access" {
  statement_id           = "AllowPublicAccess_Final" # Kita kasih nama baru biar fresh
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.visitor_counter.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

# --- 5. CloudWatch Log Group (Explicit) ---
# Penting biar log tidak disimpan selamanya (mahal) dan rapi.

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  # Namanya WAJIB persis seperti ini: /aws/lambda/<NamaFungsi>
  name              = "/aws/lambda/${aws_lambda_function.visitor_counter.function_name}"
  retention_in_days = 7 # Simpan log cuma seminggu
}

# --- 6. Blog Feature Resources ---

# DynamoDB for Blog Posts
resource "aws_dynamodb_table" "blog_table" {
  name         = "CloudResume-BlogPosts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# Archive Blog Lambda
data "archive_file" "blog_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/blog.py"
  output_path = "${path.module}/lambda/blog.zip"
}

# Blog Lambda Function
resource "aws_lambda_function" "blog_service" {
  filename         = data.archive_file.blog_lambda_zip.output_path
  function_name    = "blog_service_func"
  role             = aws_iam_role.lambda_role.arn
  handler          = "blog.handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.blog_lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.blog_table.name
    }
  }
}

# CloudWatch Log Group for Blog Lambda
resource "aws_cloudwatch_log_group" "blog_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.blog_service.function_name}"
  retention_in_days = 7
}

terraform {


  # INI BAGIAN PENTINGNYA
  backend "s3" {
    bucket  = "yusdar-tf-state-12345" # <--- GANTI DENGAN NAMA BUCKET STEP 1 TADI
    key     = "cloud-resume/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
