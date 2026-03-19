# ---------------------------------------------------------------------------
# Outputs — fed into helm values at deploy time:
#   helm upgrade vitalbridge ./helm/vitalbridge \
#     --set gcp.projectId=$(terraform output -raw project_id) \
#     --set gcp.vitalsTopic=$(terraform output -raw vitals_topic_id) \
#     --set gcp.vitalsSubscription=$(terraform output -raw vitals_subscription_id) \
#     --set gcp.archiveBucket=$(terraform output -raw vitals_archive_bucket) \
#     --set gcp.bqDataset=$(terraform output -raw bq_dataset_id) \
#     --set gcp.bqTable=$(terraform output -raw bq_table_id) \
#     --set gcp.alertSecretId=$(terraform output -raw alert_secret_id) \
#     --set serviceAccount.gcpEmail=$(terraform output -raw workload_sa_email)
# ---------------------------------------------------------------------------

output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.main.name
}

output "gke_cluster_endpoint" {
  description = "GKE cluster API endpoint"
  value       = google_container_cluster.main.endpoint
  sensitive   = true
}

output "vitals_topic_id" {
  description = "Pub/Sub vitals ingest topic ID"
  value       = google_pubsub_topic.vitals_ingest.id
}

output "vitals_subscription_id" {
  description = "Pub/Sub vitals processor subscription ID"
  value       = google_pubsub_subscription.vitals_processor.id
}

output "vitals_archive_bucket" {
  description = "GCS bucket name for raw vitals archive"
  value       = google_storage_bucket.vitals_archive.name
}

output "bq_dataset_id" {
  description = "BigQuery dataset ID for vitals readings"
  value       = google_bigquery_dataset.vitals.dataset_id
}

output "bq_table_id" {
  description = "BigQuery table ID for vitals readings"
  value       = google_bigquery_table.vitals_readings.table_id
}

output "alert_secret_id" {
  description = "Secret Manager secret ID for alert dispatcher API key"
  value       = google_secret_manager_secret.alert_api_key.secret_id
}

output "workload_sa_email" {
  description = "GCP service account email for Workload Identity binding"
  value       = google_service_account.vitalbridge_workload.email
}

output "kms_key_id" {
  description = "CMEK key ID"
  value       = google_kms_crypto_key.phi_key.id
}
