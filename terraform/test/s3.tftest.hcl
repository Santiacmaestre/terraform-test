run "apply_ok_good_policy" {
  command = apply

  variables {
    bucket_prefix          = "mi-bucket-prueba"
    use_correct_object_arn = true
  }
}

run "apply_fails_bad_policy_expected" {
  command = apply

  variables {
    bucket_prefix          = "mi-bucket-prueba"
    use_correct_object_arn = false
  }

  expect_failures = [
    aws_s3_bucket_policy.this
  ]
}
