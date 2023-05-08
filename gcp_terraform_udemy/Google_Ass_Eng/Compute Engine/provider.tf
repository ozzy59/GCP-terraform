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
  region  = "us-west4"
  zone    = "us-west4-a"
}

provider "google-beta" {
  project = "terraform-course-370521"
  region  = "us-west4"
  zone    = "us-west4-a"
}