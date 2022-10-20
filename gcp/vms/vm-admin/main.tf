locals {
  hostname = format("%s-admin", var.prefix_name)
}

// Dedicated service account for the Bastion instance.
resource "google_service_account" "admin" {
  account_id   = format("%s-admin-sa", var.prefix_name)
  display_name = format("%s Admin Service Account", upper(var.prefix_name))
}

// Allow access to the Admin Host via RDP.
resource "google_compute_firewall" "admin-rdp" {
  name          = format("%s-admin-rdp", var.prefix_name)
  network       = var.network_name
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"] // TODO: Restrict further.

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  target_tags = [local.hostname]
}

// The user-data script on Admin instance provisioning.
data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

// The Admin host.
resource "google_compute_instance" "admin" {
  name         = local.hostname
  machine_type = "e2-medium"
  zone         = var.zone
  project = var.project_id

  labels = {
    "hostname" = local.hostname
  }

  tags = [local.hostname]

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


# Solo para pruebas del apigee a la red interna
resource "google_compute_firewall" "http" {
  name          = format("%s-admin-http", var.prefix_name)
  network       = var.network_name
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}

resource "google_compute_firewall" "https" {
  name          = format("%s-admin-https", var.prefix_name)
  network       = var.network_name
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server", local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}
