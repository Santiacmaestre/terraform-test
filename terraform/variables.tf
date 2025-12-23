variable "bucket_prefix" {
  type    = string
  default = "tf-test-bucket"
}

# When true, we generate the correct object ARN (bucket/*) for s3:GetObject.
# When false, we intentionally generate a policy that targets the bucket ARN (bucket) instead of objects.
variable "use_correct_object_arn" {
  type    = bool
  default = true
}
