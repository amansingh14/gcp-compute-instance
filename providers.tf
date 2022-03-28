terraform {
  required_version = "~> 1.0"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">=1.0.0" # pinning version
    }
  }
}
# Define GCP provider
provider "google" {
  credentials = file("~/Downloads/tryme-335411-607d98fa9382.json")
  project     = local.project_name
  region      = "us-central1-a"
  zone        = "us-central1"
}