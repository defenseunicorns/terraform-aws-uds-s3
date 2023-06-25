name_prefix   = "ex-complete" # if changed, update test
force_destroy = true
tags = {
  Owner = "UDS"
  Repo  = "terraform-aws-uds-s3"
}
access_logging_enabled = false
region                 = "us-west-2"
create_irsa            = false
