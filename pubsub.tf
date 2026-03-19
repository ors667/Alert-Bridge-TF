# ---------------------------------------------------------------------------
# Pub/Sub — Vitals ingest event stream
# Patient vitals readings (HR, BP, SpO2, temp, RR) are published here by
# bedside monitor integrations. The in-cluster stream processor subscribes
# and writes to BigQuery. PHI carried in message payload — CMEK required.
# ---------------------------------------------------------------------------

resource "google_pubsub_topic" "vitals_ingest" {
  name    = "${local.app}-vitals-ingest"
  project = var.project_id
  labels  = local.labels

  kms_key_name               = google_kms_crypto_key.phi_key.id
  message_retention_duration = "86400s" # 24 hours
}

resource "google_pubsub_topic" "vitals_dlq" {
  name    = "${local.app}-vitals-dlq"
  project = var.project_id
  labels  = local.labels

  kms_key_name               = google_kms_crypto_key.phi_key.id
  message_retention_duration = "604800s" # 7 days for ops review
}

resource "google_pubsub_subscription" "vitals_processor" {
  name    = "${local.app}-vitals-processor-sub"
  topic   = google_pubsub_topic.vitals_ingest.id
  project = var.project_id
  labels  = local.labels

  ack_deadline_seconds       = 60
  message_retention_duration = "86400s"
  retain_acked_messages      = false

  expiration_policy {
    ttl = ""
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "300s"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.vitals_dlq.id
    max_delivery_attempts = 5
  }
}
