output "load_balancer_ip" {
  value       = google_compute_global_forwarding_rule.http_forwarding_rule.ip_address
  description = "Public IP of the Global HTTP Load Balancer"
}

output "instance_group" {
  value = google_compute_region_instance_group_manager.nginx_mig.name
}