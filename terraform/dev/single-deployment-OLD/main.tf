provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "weather_appv2" {
  location      = var.region
  repository_id = "weather-app-repov2"
  format        = "DOCKER"
}

resource "google_cloud_run_service" "weather_app_devv2" {
  name     = "weather-app-devv2"
  location = var.region

  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/weather-app-repov2/weather-appv2:${var.image_tag}"
        ports { container_port = 8080 }

        env {
          name  = "NODE_ENV"
          value = "dev"
        }
      }
      timeout_seconds = 300
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.weather_app_devv2.name
  location = google_cloud_run_service.weather_app_devv2.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}