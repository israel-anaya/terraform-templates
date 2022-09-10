locals {
  hostname = format("%s-weblogic", var.environment)
}

resource "google_compute_address" "external_ip" {
  name         = format("%s-weblogic-ip", var.environment)
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}

resource "google_compute_firewall" "http" {
  name          = format("%s-weblogic-http", var.environment)
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
  name          = format("%s-weblogic-https", var.environment)
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
  name          = format("%s-weblogic-console", var.environment)
  network       = var.network.name
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server", local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["7001"]
  }
}


resource "google_compute_firewall" "ssh" {
  name        = format("%s-weblogic-ssh", var.environment)
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

data "template_file" "ora_response" {
  template = file("${path.module}/files/ora-response")
}

data "template_file" "install_weblogic" {
  template = file("${path.module}/files/install-weblogic.sh")
}

data "template_file" "create_domain" {
  template = file("${path.module}/files/create-domain.sh")
}

data "template_file" "domain_model" {
  template = file("${path.module}/files/domain-model.yaml")
}

data "template_file" "domain_properties" {
  template = file("${path.module}/files/domain.properties")
}

// The user-data script on Bastion instance provisioning.
data "template_file" "startup_script" {

  template = file("${path.module}/files/startup-script.sh")
  vars = {
    BASH_PROFILE      = data.template_file.bash_profile.rendered
    ORA_RESPONSE      = data.template_file.ora_response.rendered
    INSTALL_WEBLOGIC  = data.template_file.install_weblogic.rendered
    CREATE_DOMAIN     = data.template_file.create_domain.rendered
    DOMAIN_MODEL      = data.template_file.domain_model.rendered
    DOMAIN_PROPERTIES = data.template_file.domain_properties.rendered
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
      size = 60
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