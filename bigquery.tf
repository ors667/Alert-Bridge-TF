# ---------------------------------------------------------------------------
# BigQuery — Vitals time-series storage
# The stream processor writes one row per vitals reading. Partitioned by
# reading_time for cost-efficient time-range queries. CMEK encrypted.
# ---------------------------------------------------------------------------

resource "google_bigquery_dataset" "vitals" {
  dataset_id                 = "vitalbridge_vitals"
  friendly_name              = "VitalBridge Vitals"
  description                = "PHI-bearing patient vitals readings ingested from bedside monitors"
  location                   = "US"
  delete_contents_on_destroy = false
  project                    = var.project_id
  labels                     = local.labels

  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key.phi_key.id
  }

  access {
    role          = "OWNER"
    user_by_email = google_service_account.vitalbridge_workload.email
  }
  lifecycle {
    prevent_destroy = true
}
}

resource "google_bigquery_table" "vitals_readings" {
  dataset_id          = google_bigquery_dataset.vitals.dataset_id
  table_id            = "vitals_readings"
  project             = var.project_id
  deletion_protection = true
  labels              = local.labels

  schema = jsonencode([
    { name = "reading_id",    type = "STRING",    mode = "REQUIRED", description = "Unique reading identifier" },
    { name = "patient_id",    type = "STRING",    mode = "REQUIRED", description = "De-identified patient reference" },
    { name = "device_id",     type = "STRING",    mode = "REQUIRED", description = "Bedside monitor device identifier" },
    { name = "ward_id",       type = "STRING",    mode = "REQUIRED", description = "Ward or unit identifier" },
    { name = "heart_rate",    type = "FLOAT64",   mode = "NULLABLE", description = "Heart rate (bpm)" },
    { name = "systolic_bp",   type = "FLOAT64",   mode = "NULLABLE", description = "Systolic blood pressure (mmHg)" },
    { name = "diastolic_bp",  type = "FLOAT64",   mode = "NULLABLE", description = "Diastolic blood pressure (mmHg)" },
    { name = "spo2",          type = "FLOAT64",   mode = "NULLABLE", description = "Peripheral oxygen saturation (%)" },
    { name = "temperature",   type = "FLOAT64",   mode = "NULLABLE", description = "Body temperature (°C)" },
    { name = "resp_rate",     type = "FLOAT64",   mode = "NULLABLE", description = "Respiratory rate (breaths/min)" },
    { name = "alert_flag",    type = "BOOL",      mode = "REQUIRED", description = "True if any reading breached alert threshold" },
    { name = "reading_time",  type = "TIMESTAMP", mode = "REQUIRED", description = "Timestamp of the vitals reading" },
    { name = "ingested_at",   type = "TIMESTAMP", mode = "REQUIRED", description = "Pipeline ingestion timestamp" }
  ])

  time_partitioning {
    type  = "DAY"
    field = "reading_time"
  }

  range_partitioning = null
}
