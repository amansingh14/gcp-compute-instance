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
  credentials = file("./dev-panzura-edge-d7aae08901f7.json")
  project     = local.project_name
  region      = "us-central1"
  zone        = local.zone_id
}