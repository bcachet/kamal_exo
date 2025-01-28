variable "server_names" {
  default = ["web", "db"]
}

resource "tls_private_key" "deployment_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "deployment_ssh_key" {
  content         = tls_private_key.deployment_ssh_key.private_key_pem
  filename        = "../config/private_key.pem"
  file_permission = "0400"
}

resource "exoscale_ssh_key" "deployment_ssh_key" {
  name       = "kamal-deployment-ssh-key"
  public_key = tls_private_key.deployment_ssh_key.public_key_openssh
}

data "exoscale_template" "ubuntu_template" {
  zone = "ch-gva-2"
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

resource "exoscale_instance_pool" "voting-web-ipool" {
  zone          = "ch-gva-2"
  name          = "voting-web"
  size          = 1
  template_id   = data.exoscale_template.ubuntu_template.id
  instance_type = "standard.small"
  disk_size     = 10
  key_pair      = exoscale_ssh_key.deployment_ssh_key.name
  security_group_ids = [
    exoscale_security_group.voting-http.id,
    exoscale_security_group.voting-ssh.id,
    exoscale_security_group.voting-ping.id]
}

resource "exoscale_nlb" "voting-web-nlb" {
  zone = exoscale_instance_pool.voting-web-ipool.zone
  name = "voting-web"
}

resource "exoscale_nlb_service" "voting-web-nlb-service" {
  nlb_id = exoscale_nlb.voting-web-nlb.id
  zone   = exoscale_nlb.voting-web-nlb.zone
  name   = "voting-web"

  instance_pool_id = exoscale_instance_pool.voting-web-ipool.id
  protocol         = "tcp"
  port             = 80
  target_port      = 80
  strategy         = "round-robin"

  healthcheck {
    mode     = "http"
    port     = 80
    uri      = "/healthz"
    interval = 5
    timeout  = 3
    retries  = 1
  }
}
