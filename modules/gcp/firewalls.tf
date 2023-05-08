resource "google_compute_firewall" "k8s" {
  for_each      = var.firewalls
  name          = each.key
  network       = var.network
  target_tags   = each.value.target_tags
  source_ranges = each.value.source_ranges

  allow {
    protocol = each.value.protocol
    ports    = each.value.ports
  }
}