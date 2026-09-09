# ---------------------------------------------------------------------------
# KMS — Customer-Managed Encryption Key (CMEK)
# Shared key applied to all PHI data stores: Pub/Sub, BigQuery, Secret Manager.
# 90-day rotation; 30-day destruction window per security policy.
# ---------------------------------------------------------------------------

resource "google_kms_key_ring" "phi_keyring" {
  name     = "alert-bridge-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "phi_key" {
  name            = "${local.app}-cmek"
  key_ring        = google_kms_key_ring.phi_keyring.id
  rotation_period = "7776000s" # 90 days
  destroy_scheduled_duration = "2592000s" # 30 days

  lifecycle {
    prevent_destroy = true
  }
}
