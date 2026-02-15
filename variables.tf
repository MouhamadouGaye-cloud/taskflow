variable "project_id" {}
variable "region" { default = "us-central1" }
variable "credentials_file" { default = "key.json" }
variable "frontend_bucket_name" {}
variable "api_image" {}   # e.g., gcr.io/terraform-html-demo/taskflow-api:latest
