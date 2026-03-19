# ---------------------------------------------------------------------------
# GCS — Raw vitals archive bucket
# The stream processor writes raw Pub/Sub message payloads here before
# parsing and writing to BigQuery. Provides a replayable raw data store
# for pipeline recovery and audit. Retention set to 7 years per HIPAA policy.
# ---------------------------------------------------------------------------

resource "google_storage_bucket" "vitals_archive" {
  name                        = "${var.project_id}-${local.app}-vitals-archive"
  location                    = var.region
  storage_class               = "STANDARD"
  force_destroy               = false
  uniform_bucket_level_access = true
  project                     = var.project_id
  labels                      = local.labels

  versioning {
    enabled = true
  }

  retention_policy {
    retention_period = 220752000 # 7 years in seconds
    is_locked        = true
  }

  lifecycle_rule {
    condition { age = 90 }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition { age = 365 }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition { age = 2557 }
    action { type = "Delete" }
  }
}

resource "google_storage_bucket_iam_member" "vitals_archive_workload" {
  bucket = google_storage_bucket.vitals_archive.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.vitalbridge_workload.email}"
}
