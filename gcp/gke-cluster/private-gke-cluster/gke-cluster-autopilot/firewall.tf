/******************************************
  Allow GKE master to hit non 443 ports for
  Webhooks/Admission Controllers
  https://github.com/kubernetes/kubernetes/issues/79739
 *****************************************/
resource "google_compute_firewall" "master_webhooks" {
  name        = format("%s-webhooks", var.cluster_name)
  description = "Managed by terraform gke module: Allow master to hit pods for admission controllers/webhooks"
  project     = var.project_id
  network     = var.network.name
  #priority    = var.firewall_priority
  direction = "INGRESS"

  source_ranges = [google_container_cluster.primary.private_cluster_config.0.master_ipv4_cidr_block]
  source_tags   = []
  target_tags   = ["${var.cluster_name}-node"]

  allow {
    protocol = "tcp"
    ports    = [8443]
  }

  depends_on = [
    google_container_cluster.primary,
  ]

}