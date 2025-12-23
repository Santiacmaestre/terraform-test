resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  lifecycle {
    # Make the "bad policy" case deterministic and testable with terraform test.
    # If you want AWS itself to reject it, remove this precondition and let the provider/API error surface.
    precondition {
      condition     = var.use_correct_object_arn
      error_message = "Policy rejected by module rules: s3:GetObject must target object ARNs (arn:aws:s3:::bucket/*), not the bucket ARN (arn:aws:s3:::bucket)."
    }
  }
}
