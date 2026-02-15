provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_file)
}

# GCS bucket for frontend
resource "google_storage_bucket" "frontend_bucket" {
  name     = var.frontend_bucket_name
  location = var.region

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  uniform_bucket_level_access = true
  force_destroy               = true
}

# Make bucket public
resource "google_storage_bucket_iam_binding" "public" {
  bucket = google_storage_bucket.frontend_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}

# Cloud Run service for API
resource "google_cloud_run_service" "api" {
  name     = "taskflow-api"
  location = var.region

  template {
    spec {
      containers {
        image = var.api_image  # Pass the Docker image from GitHub B
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Allow public access to Cloud Run
resource "google_cloud_run_service_iam_binding" "public" {
  location    = google_cloud_run_service.api.location
  project     = var.project_id
  service     = google_cloud_run_service.api.name
  role        = "roles/run.invoker"
  members     = ["allUsers"]
}

# Outputs
output "cloud_run_url" {
  value = google_cloud_run_service.api.status[0].url
}

output "frontend_bucket_url" {
  value = google_storage_bucket.frontend_bucket.url
}
