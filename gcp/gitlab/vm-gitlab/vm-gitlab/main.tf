locals {
  hostname = format("%s-gitlab", var.environment)
}

resource "google_compute_address" "external_ip" {
  name         = format("%s-gitlab-ip", var.environment)
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}

resource "google_compute_firewall" "http" {
  name          = format("%s-gitlab-http", var.environment)
  network       = var.network.name
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "https" {
  name          = format("%s-gitlab-https", var.environment)
  network       = var.network.name
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server", local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "registry" {
  name          = format("%s-gitlab-registry", var.environment)
  network       = var.network.name
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["5050"]
  }
}

resource "google_compute_firewall" "ssh" {
  name        = format("%s-gitlab-ssh", var.environment)
  network     = var.network.name
  direction   = "INGRESS"
  project     = var.project_id
  source_tags = [var.bastion_hostname]
  target_tags = [local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}



// The user-data script on Bastion instance provisioning.
data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y curl wget openssh-server ca-certificates
  curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
  
  EOF
}

// The GitLab instance
resource "google_compute_instance" "instance" {
  name         = local.hostname
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  labels = {
    "env" = var.environment
  }

  tags = ["http-server", "https-server", local.hostname]


  boot_disk {
    initialize_params {
      size  = 250
      type  = "pd-ssd"
      image = "debian-cloud/debian-10"
    }
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata_startup_script = data.template_file.startup_script.rendered

  network_interface {
    subnetwork = var.subnetwork.name


    access_config {
      nat_ip       = google_compute_address.external_ip.address
      network_tier = "STANDARD"
    }
  }

  // Allow the instance to be stopped by Terraform when updating configuration.
  allow_stopping_for_update = true

  service_account {
    email  = var.service_account.email
    scopes = ["cloud-platform"]
  }

  scheduling {
    preemptible       = false
    automatic_restart = false
  }
}