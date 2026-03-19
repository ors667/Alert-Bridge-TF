# ---------------------------------------------------------------------------
# Cloud Functions (Gen 2) — Alert dispatcher
# Triggered by the in-cluster alert evaluator via Pub/Sub when a patient's
# vitals breach a critical threshold. Dispatches notifications to the
# hospital's clinical alerting platform using the Secret Manager API key.
# Runs in the functions subnet; no public ingress.
# ---------------------------------------------------------------------------

resource "google_cloudfunctions2_function" "alert_dispatcher" {
  name     = "${local.app}-alert-dispatcher"
  location = var.region
  project  = var.project_id
  labels   = local.labels

  description = "Dispatches critical vitals alerts to the hospital notification platform"

  build_config {
    runtime     = "python311"
    entry_point = "dispatch_alert"
    source {
      storage_source {
        bucket = google_storage_bucket.vitals_archive.name
        object = "functions/alert-dispatcher.zip"
      }
    }
  }

  service_config {
    min_instance_count             = 1
    max_instance_count             = 10
    available_memory               = "256M"
    timeout_seconds                = 60
    service_account_email          = google_service_account.vitalbridge_workload.email
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true

    secret_environment_variables {
      key        = "ALERT_API_KEY"
      project_id = var.project_id
      secret     = google_secret_manager_secret.alert_api_key.secret_id
      version    = "latest"
    }

    environment_variables = {
      GCP_PROJECT  = var.project_id
      ENVIRONMENT  = var.environment
      ALERT_EMAIL  = var.alert_email
    }

    vpc_connector                  = null
    vpc_connector_egress_settings  = null
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.vitals_ingest.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}
