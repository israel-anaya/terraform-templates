locals {
  hostname = format("%s-bastion", var.cluster_name)
}

// Dedicated service account for the Bastion instance.
resource "google_service_account" "bastion" {
  account_id   = format("%s-bastion-sa", var.cluster_name)
  display_name = format("%s Bastion Service Account", upper(var.cluster_name))
}

// Allow access to the Bastion Host via SSH.
resource "google_compute_firewall" "bastion-ssh" {
  name          = format("%s-bastion-ssh", var.cluster_name)
  network       = var.network_name
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"] // TODO: Restrict further.

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["gke-cluster", "${var.cluster_name}"]
}

// The user-data script on Bastion instance provisioning.
data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

// The Bastion host.
resource "google_compute_instance" "bastion" {
  name         = local.hostname
  project      = var.project_id
  zone         = var.zone
  machine_type = "e2-micro"

  labels = {
    "gke-cluster" = var.cluster_name
  }

  tags = ["gke-cluster", "${var.cluster_name}"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  // Install tinyproxy on startup.
  metadata_startup_script = data.template_file.startup_script.rendered

  network_interface {
    subnetwork = var.subnetwork_name


    access_config {
      // Not setting "nat_ip", use an ephemeral external IP.
      network_tier = "STANDARD"
    }
  }

  // Allow the instance to be stopped by Terraform when updating configuration.
  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }

  /* local-exec providers may run before the host has fully initialized.
  However, they are run sequentially in the order they were defined.
  This provider is used to block the subsequent providers until the instance is available. */
  provisioner "local-exec" {
    command = <<EOF
        READY=""
        for i in $(seq 1 20); do
          if gcloud compute ssh ${local.hostname} --project ${var.project_id} --zone ${var.region}-a --command uptime; then
            READY="yes"
            break;
          fi
          echo "Waiting for ${local.hostname} to initialize..."
          sleep 10;
        done
        if [[ -z $READY ]]; then
          echo "${local.hostname} failed to start in time."
          echo "Please verify that the instance starts and then re-run `terraform apply`"
          exit 1
        fi
EOF
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}