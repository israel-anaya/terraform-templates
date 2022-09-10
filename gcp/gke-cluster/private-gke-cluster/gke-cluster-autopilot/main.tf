resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.

  # remove_default_node_pool = true
  initial_node_count = 1

  network    = var.network.name
  subnetwork = var.subnetwork.name

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  // Allocate IPs in our subnetwork
  ip_allocation_policy {
    #use_ip_aliases                = true
    cluster_secondary_range_name  = var.subnetwork.secondary_ip_range.0.range_name
    services_secondary_range_name = var.subnetwork.secondary_ip_range.1.range_name
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "08:00" # GTM
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.authorized_ipv4_cidr_block != null ? [var.authorized_ipv4_cidr_block] : []
    content {
      cidr_blocks {
        cidr_block   = master_authorized_networks_config.value
        display_name = "External Control Plane access"
      }
    }
  }

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.16/28"
  }

  release_channel {
    channel = "STABLE"
  }

  #workload_identity_config {
  #  workload_pool = format("%s.svc.id.goog", var.project_id)
  #}

  enable_autopilot = true

  node_config {
    preemptible  = true
    disk_size_gb = 50

    machine_type = var.machine_type

    // Use the cluster created service account for this node pool
    service_account = var.service_account

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    shielded_instance_config {
      enable_secure_boot = true
    }

    // Enable workload identity on this node pool.
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = {
      // Set metadata on the VM to supply more entropy.
      google-compute-enable-virtio-rng = "true"
      // Explicitly remove GCE legacy metadata API endpoint.
      disable-legacy-endpoints = "true"
    }

    labels = {
      "cluster-name" = var.cluster_name
    }

    tags = ["${var.cluster_name}-node"]
  }
}

