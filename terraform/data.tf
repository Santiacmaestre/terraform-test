data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AllowReadObjectsInAccount"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
  }
}

