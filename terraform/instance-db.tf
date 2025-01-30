resource "exoscale_compute_instance" "db" {
  zone = var.zone
  name = "db"

  template_id        = data.exoscale_template.ubuntu_template.id
  type               = "standard.medium"
  disk_size          = 100
  ssh_key            = exoscale_ssh_key.deployment_ssh_key.name
  security_group_ids = [exoscale_security_group.db.id]
  user_data          = file("./cloud-init.yml")
}
