# Instance Template

resource "google_compute_instance_template" "nginx_template" {
  name                 = "nginx-template"
  machine_type         = "e2-medium"
  can_ip_forward       = false

  tags = ["http-server"]

  disk {
    source_image = "projects/debian-cloud/global/images/family/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    access_config {}   # required for external IP
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install nginx -y
    systemctl enable nginx
    systemctl start nginx
  EOF
}

# Managed Instance Group (MIG)

resource "google_compute_region_instance_group_manager" "nginx_mig" {
  name               = "nginx-mig"
  base_instance_name = "nginx"
  region             = var.region
  version {
    instance_template = google_compute_instance_template.nginx_template.self_link
  }
  target_size = 3
  }