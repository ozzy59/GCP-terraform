resource "google_storage_bucket" "GCS1" {
  name          = "first-bucket-on-this-acc"
  storage_class = "STANDARD"
  location      = "EUROPE-CENTRAL2"

  labels = {
    "env" = "tf_test"
  }

  uniform_bucket_level_access = false

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 1
    }
  }

}

resource "google_storage_bucket_object" "file" {
  name   = "test_script"
  bucket = google_storage_bucket.GCS1.name
  source = "test.sh"
}

