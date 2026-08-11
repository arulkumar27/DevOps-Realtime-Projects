# The bucket, region and state key are supplied during terraform init.
# This keeps account-specific backend values out of the source code.
terraform {
  backend "s3" {
    use_lockfile = true
    encrypt      = true
  }
}