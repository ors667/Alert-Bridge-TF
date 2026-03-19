# ---------------------------------------------------------------------------
# GKE — Private cluster for VitalBridge workloads
# Private nodes (no public IPs); control plane authorised networks restricted.
# Workload Identity enabled for secure pod-level GCP service access.
# Node pool autoscales between min and max per zone.
# ---------------------------------------------------------------------------

resource "google_container_cluster" "main" {
  name     = var.gke_cluster_name
  location = var.region
  project  = var.project_id

  # Remove default node pool; managed separately for lifecycle flexibility
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.main.id
  subnetwork = google_compute_subnetwork.gke_nodes.id

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  maintenance_policy {
    recurring_window {
      start_time = "2024-01-01T04:00:00Z"
      end_time   = "2024-01-01T08:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SU"
    }
  }

  deletion_protection = true
}

resource "google_container_node_pool" "main" {
  name     = "${local.app}-node-pool"
  cluster  = google_container_cluster.main.id
  location = var.region
  project  = var.project_id

  autoscaling {
    min_node_count = var.node_pool_min_count
    max_node_count = var.node_pool_max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.node_pool_machine_type
    disk_type       = "pd-ssd"
    disk_size_gb    = 100
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.vitalbridge_workload.email

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    labels = local.labels

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
