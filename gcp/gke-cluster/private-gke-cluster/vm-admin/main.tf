locals {
  hostname = format("%s-admin", var.cluster_name)
}

// Dedicated service account for the Bastion instance.
resource "google_service_account" "admin" {
  account_id   = format("%s-admin-sa", var.cluster_name)
  display_name = format("%s Admin Service Account", var.cluster_name)
}

// Allow access to the Bastion Host via SSH.
resource "google_compute_firewall" "admin-ssh" {
  name          = format("%s-admin-ssh", var.cluster_name)
  network       = var.network_name
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"] // TODO: Restrict further.

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  target_tags = ["gke-cluster-admin", "${var.cluster_name}"]
}

// The user-data script on Bastion instance provisioning.
data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

// The Bastion host.
resource "google_compute_instance" "admin" {
  name         = local.hostname
  machine_type = "e2-medium"
  zone         = var.zone
  project      = var.project_id

  labels = {
    "cluster-name" = var.cluster_name
  }

  tags = ["gke-cluster-admin", "${var.cluster_name}"]

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2012-r2"
    }
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  // Install startup.
  #metadata_startup_script = data.template_file.startup_script.rendered

  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork_name


    access_config {
      // Not setting "nat_ip", use an ephemeral external IP.
      #network_tier = "STANDARD"
    }
  }

  // Allow the instance to be stopped by Terraform when updating configuration.
  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.admin.email
    scopes = ["cloud-platform"]
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}