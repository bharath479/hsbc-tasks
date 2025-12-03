variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for MIG"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Default compute zone"
  type        = string
  default     = "us-central1-a"
}
variable "credentials_file" {
  description = "Path to the GCP credentials JSON file"
  type        = string
}