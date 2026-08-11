# Creates the S3 bucket used to store Terraform state.
resource "aws_s3_bucket" "terraform_state" {
  bucket        = local.state_bucket_name
  force_destroy = false

  # Prevents accidental deletion of the state bucket.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = local.state_bucket_name
    Purpose = "Terraform remote state"
  }
}

# Enables versioning so previous Terraform states can be recovered.
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Manages old state versions and incomplete uploads.
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  depends_on = [
    aws_s3_bucket_versioning.terraform_state
  ]

  rule {
    id     = "terraform-state-retention"
    status = "Enabled"

    filter {}

    # Delete old state-file versions after 90 days.
    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    # Delete incomplete uploads after seven days.
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Encrypts Terraform state using the AWS-managed S3 KMS key.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "alias/aws/s3"
    }

    # Reduces the number of direct requests made to AWS KMS.
    bucket_key_enabled = true
  }
}

# Blocks all public access to the Terraform state bucket.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Disables ACL-based ownership and gives the bucket owner full control.
resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Generates a bucket policy that denies insecure HTTP connections.
data "aws_iam_policy_document" "require_secure_transport" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# Attaches the HTTPS-only policy to the state bucket.
resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.require_secure_transport.json

  depends_on = [
    aws_s3_bucket_public_access_block.terraform_state
  ]
}

# Sends S3 state-bucket events to Amazon EventBridge.
# EventBridge rules can later detect unexpected state-file changes.
resource "aws_s3_bucket_notification" "terraform_state" {
  bucket      = aws_s3_bucket.terraform_state.id
  eventbridge = true

  depends_on = [
    aws_s3_bucket_policy.terraform_state
  ]
}