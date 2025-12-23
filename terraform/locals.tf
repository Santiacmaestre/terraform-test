locals {
  # Correct for object-level permissions.
  correct_resource_arn   = "${aws_s3_bucket.this.arn}/*"
  incorrect_resource_arn = aws_s3_bucket.this.arn

  selected_resource_arn = var.use_correct_object_arn ? local.correct_resource_arn : local.incorrect_resource_arn
}

locals {
  # Keep the bucket name DNS-compliant (lowercase, digits, hyphens).
  bucket_name = lower("${var.bucket_prefix}-${random_id.suffix.hex}")
}
