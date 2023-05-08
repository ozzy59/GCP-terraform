resource "google_service_account" "test-vm-1" {
  account_id   = "test-vm-1"
  display_name = "test"
}

resource "google_compute_disk" "test-disk-2" {
  name = "test-disk-2"
  size = 10
  zone = "europe-central2-a"
  type = "pd-ssd"
}

resource "google_compute_attached_disk" "test-disk-2-attached" {
  disk     = google_compute_disk.test-disk-2.name
  instance = google_compute_instance.instance-1-tf.name

}

resource "google_compute_instance" "instance-1-tf" {
  name                      = "instance1"
  zone                      = "europe-central2-a"
  machine_type              = "n1-standard-1"
  allow_stopping_for_update = true

  network_interface {
    network    = "custom-vpc-tf"
    subnetwork = "sub-pl"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20221201"
      size  = 20
    }
    #auto_delete = false
  }

  service_account {
    email  = google_service_account.test-vm-1.email
    scopes = ["monitoring-read"]
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }

  labels = {
    "owner" = "so"
    "env"   = "dev"
  }
}