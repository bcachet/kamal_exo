resource "exoscale_instance_pool" "web-ipool" {
  zone               = var.zone
  name               = "web"
  size               = 1
  template_id        = data.exoscale_template.ubuntu_template.id
  instance_type      = "standard.small"
  disk_size          = 10
  key_pair           = exoscale_ssh_key.deployment_ssh_key.name
  security_group_ids = [exoscale_security_group.web.id]
}

resource "exoscale_nlb" "web-nlb" {
  zone = exoscale_instance_pool.web-ipool.zone
  name = "web"
}

resource "exoscale_nlb_service" "web-nlb-service" {
  nlb_id = exoscale_nlb.web-nlb.id
  zone   = exoscale_nlb.web-nlb.zone
  name   = "web"

  instance_pool_id = exoscale_instance_pool.web-ipool.id
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
