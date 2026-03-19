variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Primary GCP region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "gke_cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "vitalbridge-cluster"
}

variable "node_pool_machine_type" {
  description = "GKE node pool machine type"
  type        = string
  default     = "e2-standard-4"
}

variable "node_pool_min_count" {
  description = "Minimum nodes per zone in the GKE node pool"
  type        = number
  default     = 1
}

variable "node_pool_max_count" {
  description = "Maximum nodes per zone in the GKE node pool"
  type        = number
  default     = 5
}

variable "alert_function_image" {
  description = "Container image URI for the Cloud Functions alert dispatcher"
  type        = string
}

variable "alert_email" {
  description = "Email address for critical vitals alert notifications"
  type        = string
}
