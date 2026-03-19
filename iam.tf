# ---------------------------------------------------------------------------
# IAM — Workload Identity service account for VitalBridge pods
# Pods assume this GCP identity via Kubernetes Workload Identity binding.
# Scoped to the specific GCP resources VitalBridge pods need to access.
# ---------------------------------------------------------------------------

resource "google_service_account" "vitalbridge_workload" {
  account_id   = "${local.app}-workload-sa"
  display_name = "VitalBridge Workload SA"
  description  = "GCP identity for VitalBridge pods via Workload Identity"
  project      = var.project_id
}

# Subscribe to the vitals ingest Pub/Sub subscription
resource "google_project_iam_member" "workload_pubsub_subscriber" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.vitalbridge_workload.email}"
}

# Publish to Pub/Sub (processor publishes alerts to the alert topic)
resource "google_project_iam_member" "workload_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.vitalbridge_workload.email}"
}

# Write vitals readings to BigQuery
resource "google_project_iam_member" "workload_bigquery_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.vitalbridge_workload.email}"
}

# Write raw vitals archives to GCS
resource "google_project_iam_member" "workload_storage_creator" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_service_account.vitalbridge_workload.email}"
}

# Access application secrets at runtime
resource "google_project_iam_member" "workload_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.vitalbridge_workload.email}"
}

# Workload Identity binding — allows the K8s SA to impersonate this GCP SA
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.vitalbridge_workload.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[vitalbridge/vitalbridge-sa]"
}
