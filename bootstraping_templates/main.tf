# Create the KMS Key
resource "aws_kms_key" "tfbootstrap" {
  description             = "S3 Encryption Key"
  deletion_window_in_days = 15
  multi_region            = false
  tags                    = { Name = "${var.name-prefix}-kms-key" }
}

# Create the Bucket
resource "aws_s3_bucket" "tfbootstrap" {
  bucket = var.bucket_name

  tags = { Name = "${var.name-prefix}-s3" }
}

# Enable Versioning on Bucket
resource "aws_s3_bucket_versioning" "tfbootstrap" {
  bucket = aws_s3_bucket.tfbootstrap.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access to the bucket and objects
resource "aws_s3_bucket_public_access_block" "tfbootstrap" {
  bucket = aws_s3_bucket.tfbootstrap.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enble Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "tfbootstrap" {
  bucket = aws_s3_bucket.tfbootstrap.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tfbootstrap.arn
      sse_algorithm     = "aws:kms"
    }
  }

  depends_on = [aws_kms_key.tfbootstrap]
}

# Create the DynamoDB Table and Partition key
resource "aws_dynamodb_table" "tfbootstrap" {
  name         = var.table_name
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = { Name = "${var.name-prefix}-dynamodb" }
}