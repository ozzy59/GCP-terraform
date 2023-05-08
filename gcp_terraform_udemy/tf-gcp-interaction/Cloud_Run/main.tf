

resource "google_cloud_run_service" "hello-app-run" {
  name = "hello-app-run"
  location = "europe-central2"
  
  template {
    spec {
      containers {
        #image = "gcr.io/google-samples/hello-app:1.0"
        image = "gcr.io/google-samples/hello-app:2.0"
      }
    }
  }

  traffic {
    revision_name = "hello-app-run-8zfl5"
    percent = 50
  }

  traffic {
    revision_name = "hello-app-run-sdnz6"
    percent = 50
  }

}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  #location = google_cloud_run_service.hello-app-run.location
  #project = google_cloud_run_service.hello-app-run.project
  service     = google_cloud_run_service.hello-app-run.name
  policy_data = data.google_iam_policy.noauth.policy_data
}