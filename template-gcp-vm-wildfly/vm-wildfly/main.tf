locals {
  hostname = format("%s-wildfly", var.environment)
}

resource "google_compute_address" "external_ip" {
  name         = format("%s-wildfly-ip", var.environment)
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}

resource "google_compute_firewall" "http" {
  name          = format("%s-wildfly-http", var.environment)
  network       = var.network.name
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}

resource "google_compute_firewall" "https" {
  name          = format("%s-wildfly-https", var.environment)
  network       = var.network.name
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server", local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "console" {
  name          = format("%s-wildfly-console", var.environment)
  network       = var.network.name
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server", local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["9990"]
  }
}


resource "google_compute_firewall" "ssh" {
  name        = format("%s-wildfly-ssh", var.environment)
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

data "template_file" "bash_profile" {
  template = file("${path.module}/files/.bash_profile")
}

data "template_file" "wildfly_config" {
  template = file("${path.module}/files/wildfly.conf")
}

data "template_file" "wildfly_install" {
  template = file("${path.module}/files/install-wildfly.sh")
}

data "template_file" "wildfly_launch" {
  template = file("${path.module}/files/launch.sh")
}

data "template_file" "wildfly_service" {
  template = file("${path.module}/files/wildfly.service")
}


// The user-data script on Bastion instance provisioning.
data "template_file" "startup_script" {

  template = file("${path.module}/files/startup-script.sh")
  vars = {
    BASH_PROFILE = data.template_file.bash_profile.rendered
    WILDFLY_CONFIG = data.template_file.wildfly_config.rendered
    WILDFLY_INSTALL = data.template_file.wildfly_install.rendered
    WILDFLY_LAUNCH = data.template_file.wildfly_launch.rendered
    WILDFLY_SERVICE = data.template_file.wildfly_service.rendered
  }
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
      size  = 60
      #type  = "pd-ssd"
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