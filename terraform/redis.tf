resource "exoscale_compute_instance" "redis" {
  zone = var.zone
  name = "redis"

  template_id        = data.exoscale_template.ubuntu_template.id
  type               = "standard.medium"
  disk_size          = 100
  ssh_key            = exoscale_ssh_key.deployment_ssh_key.name
  security_group_ids = [exoscale_security_group.redis.id]
}
