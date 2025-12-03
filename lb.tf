# Health Check
###############################################################################
resource "google_compute_health_check" "nginx_healthcheck" {
  name = "nginx-healthcheck"

  http_health_check {
    port = 80
  }

  check_interval_sec = 5
  timeout_sec        = 5
}

###############################################################################
# Backend Service (Connects MIG to Load Balancer)
###############################################################################
resource "google_compute_backend_service" "nginx_backend" {
  name                  = "nginx-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.nginx_healthcheck.self_link]

  backend {
    group = google_compute_region_instance_group_manager.nginx_mig.instance_group
  }
}

###############################################################################
# URL Map – routes traffic to backend
###############################################################################
resource "google_compute_url_map" "nginx_url_map" {
  name            = "nginx-url-map"
  default_service = google_compute_backend_service.nginx_backend.self_link
}

###############################################################################
# HTTP Proxy
###############################################################################
resource "google_compute_target_http_proxy" "nginx_http_proxy" {
  name    = "nginx-http-proxy"
  url_map = google_compute_url_map.nginx_url_map.self_link
}

###############################################################################
# Global Forwarding Rule (Public IP)
###############################################################################
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name                  = "nginx-http-forwarder"
  target                = google_compute_target_http_proxy.nginx_http_proxy.self_link
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
}

###############################################################################
# Firewall rule for HTTP traffic to instances
###############################################################################
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}