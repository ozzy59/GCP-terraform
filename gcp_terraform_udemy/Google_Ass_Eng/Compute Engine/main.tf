resource "google_service_account" "test-vm-1" {
  account_id   = "test-vm-1"
  display_name = "test"
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

resource "google_compute_address" "external_ip" {
  name         = "external-ip"
  address_type = "EXTERNAL"
  region       = "us-west4"
}

/*
resource "google_compute_instance_from_template" "web-server-default-dev" {
  name                      = "web-server-dev-${count.index}"
  zone                      = "us-west4-a"
  allow_stopping_for_update = true
  count = 2

  source_instance_template = google_compute_instance_template.webserver.self_link

}
*/

resource "google_compute_instance_template" "webserver" {
  name                    = "webserver-template"
  machine_type            = "e2-medium"
  metadata_startup_script = "${file("dupa.sh")}"
  tags                    = ["web"]
  region                  = "us-west4"

  disk {
    source_image = data.google_compute_image.debian-image.self_link
    auto_delete  = true
    boot         = true
    disk_size_gb = 10
  }

  network_interface {
    network = "default"

    #access_config {
      #nat_ip = google_compute_address.external_ip.address
    #}
  }

  service_account {
    email  = google_service_account.test-vm-1.email
    scopes = ["monitoring-read"]
  }

  labels = {
    "env"      = "test"
    "business" = "sales"
  }
}

/*
resource "google_compute_machine_image" "web_startup" {
  provider        = google-beta
  name            = "web-startup"
  source_instance = google_compute_instance_from_template.web-server-default-dev.name
}
*/

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

resource "google_compute_instance_group_manager" "test_so" {
  name               = "test-so"
  base_instance_name = "test-so"

  version {
    instance_template = google_compute_instance_template.webserver.id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 60
  }
}

resource "google_compute_autoscaler" "test_so" {
  name   = "test-so"
  target = google_compute_instance_group_manager.test_so.id

  autoscaling_policy {
    min_replicas    = 2
    max_replicas    = 3
    cooldown_period = 60
  }
}

resource "google_compute_region_health_check" "elb" {
  name = "http-region-health-check"

  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 4
  unhealthy_threshold = 5

  http_health_check {
    port = "80"
  }
}

resource "google_compute_region_backend_service" "elb" {
  name                  = "l7-elb-web-backend"
  region                = "us-west4"
  provider              = google-beta
  protocol              = "TCP"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.elb.id]

  backend {
    group           = google_compute_instance_group_manager.test_so.instance_group
  }
}

resource "google_compute_forwarding_rule" "elb" {
  name                  = "l7-elb-web-frontend"
  provider              = google-beta
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
  port_range            = "80"
  backend_service       = google_compute_region_backend_service.elb.id
  ip_address            = google_compute_address.external_ip.id
}

