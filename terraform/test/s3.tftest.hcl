run "apply_ok" {
  command = apply

  variables {
    bucket_name = "mi-bucket-prueba-1234567890"
  }
}

run "apply_rejected_by_precondition" {
  command = apply

  variables {
    bucket_name = "BAD_BUCKET_NAME"
  }

  expect_failures = [
    aws_s3_bucket.this
  ]
}
