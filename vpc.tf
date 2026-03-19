# ---------------------------------------------------------------------------
# VPC — Private network for GKE cluster and Cloud Functions
# GKE nodes use private IPs; outbound internet via Cloud NAT only.
# Secondary IP ranges provide dedicated address space for pods and services.
# ---------------------------------------------------------------------------

resource "google_compute_network" "main" {
  name                    = "${local.app}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  project                 = var.project_id
}

resource "google_compute_subnetwork" "gke_nodes" {
  name                     = "${local.app}-gke-nodes"
  ip_cidr_range            = "10.10.0.0/22"
  region                   = var.region
  network                  = google_compute_network.main.id
  project                  = var.project_id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.30.0.0/20"
  }
}

resource "google_compute_subnetwork" "functions" {
  name                     = "${local.app}-functions"
  ip_cidr_range            = "10.10.8.0/28"
  region                   = var.region
  network                  = google_compute_network.main.id
  project                  = var.project_id
  private_ip_google_access = true
}

resource "google_compute_router" "main" {
  name    = "${local.app}-router"
  region  = var.region
  network = google_compute_network.main.id
  project = var.project_id
}

resource "google_compute_router_nat" "main" {
  name                               = "${local.app}-nat"
  router                             = google_compute_router.main.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
