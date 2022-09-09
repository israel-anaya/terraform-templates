locals {
  hostname = format("%s-bastion", var.environment)
}

// Allow access to the Bastion Host via SSH.
resource "google_compute_firewall" "ssh" {
  name          = format("%s-bastion-ssh", var.environment)
  network       = var.network.name
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"] // TODO: Restrict further.
  target_tags   = [local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }


}

// The user-data script on Bastion instance provisioning.
data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

// The Bastion host.
resource "google_compute_instance" "instance" {
  name         = local.hostname
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  labels = {
    "env" = var.environment
  }

  tags = [local.hostname]

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
    subnetwork = var.subnetwork.name


    access_config {
      // Not setting "nat_ip", use an ephemeral external IP.
      network_tier = "STANDARD"
    }
  }

  // Allow the instance to be stopped by Terraform when updating configuration.
  allow_stopping_for_update = true

  service_account {
    email  = var.service_account.email
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
    preemptible       = false
    automatic_restart = false
  }
}