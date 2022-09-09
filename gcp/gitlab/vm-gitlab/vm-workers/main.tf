
locals {
  hostname = format("%s-workers", var.environment)
}

resource "google_compute_firewall" "sql_proxy" {
  name        = format("%s-sql-proxy", var.environment)
  network     = var.network.name
  project     = var.project_id
  source_tags = var.allow_db_hostname
  target_tags = [local.hostname]

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
}

resource "google_compute_firewall" "ssh" {
  name        = format("%s-workers-ssh", var.environment)
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
data "template_file" "proxy_sql" {
  template = file("${path.module}/proxy-sql.sh")

  vars = {
    connection_name = var.connection_name
  }
}

data "template_file" "shared_runner" {
  template = file("${path.module}/shared-runner.sh")
}

data "template_file" "startup_script" {
  template = file("${path.module}/startup-script.sh")

  vars = {
    PROXY_SQL     = data.template_file.proxy_sql.rendered
    SHARED_RUNNER = data.template_file.shared_runner.rendered
  }
}

// The GitLab workers host.
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
      size  = 100
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