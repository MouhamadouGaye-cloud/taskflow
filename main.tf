provider "google" {
  project     = "terraform-html-demo"
  region      = "us-central1"
  credentials = file("key.json")
}

# GCS Static Site
resource "google_storage_bucket" "website" {
  name     = "taskflow-app"
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_binding" "public" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  members = ["allUsers"]
}

# Cloud Run API
resource "google_cloud_run_service" "api" {
  name     = "taskflow-api"
  location = "us-central1"
  template {
    spec {
      containers {
        image = "gcr.io/terraform-html-demo/taskflow-api"
        ports { container_port = 8080 }
      }
    }
  }
}

resource "google_cloud_run_service_iam_binding" "public" {
  location = google_cloud_run_service.api.location
  project  = google_cloud_run_service.api.project
  service  = google_cloud_run_service.api.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]
}

# Firestore Database
resource "google_project_service" "firestore" {
  service = "firestore.googleapis.com"
}

resource "google_firestore_database" "default" {
  name        = "(default)"
  project     = "terraform-html-demo"
  location_id = "us-central"
  type        = "FIRESTORE_NATIVE"
}
