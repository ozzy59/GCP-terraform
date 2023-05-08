resource "google_compute_network" "auto-vpc-tf" {
  name                    = "auto-vpc-tf"
  auto_create_subnetworks = true
}

resource "google_compute_network" "custom-vpc-tf" {
  name                    = "custom-vpc-tf"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "sub-pl" {
  name                     = "sub-pl"
  network                  = google_compute_network.custom-vpc-tf.id
  ip_cidr_range            = "10.0.1.0/24"
  region                   = "europe-central2"
  private_ip_google_access = true
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.custom-vpc-tf.id

  allow {
    protocol = "tcp"
    ports = [ "22" ]
  }
  source_ranges = ["0.0.0.0/0"]
  priority      = 321
}
