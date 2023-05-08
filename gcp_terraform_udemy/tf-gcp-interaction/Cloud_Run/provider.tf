terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.44.1"
    }
  }
}

provider "google" {
  project = "terraform-course-370521"
  region  = "europe-central2"
  zone    = "europe-central2-a"
}

