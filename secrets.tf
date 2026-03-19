# ---------------------------------------------------------------------------
# Secret Manager — Alert dispatcher API key
# Used by the Cloud Functions alert dispatcher to authenticate with the
# hospital notification platform. CMEK encrypted; single-region replication.
# ---------------------------------------------------------------------------

resource "google_secret_manager_secret" "alert_api_key" {
  secret_id = "${local.app}-alert-api-key"
  project   = var.project_id
  labels    = local.labels

  replication {
    user_managed {
      replicas {
        location = var.region
        customer_managed_encryption {
          kms_key_name = google_kms_crypto_key.phi_key.id
        }
      }
    }
  }
}

resource "google_secret_manager_secret_version" "alert_api_key_v1" {
  secret      = google_secret_manager_secret.alert_api_key.id
  secret_data = "placeholder-rotate-before-production"
}
