variable "server_names" {
  default = ["web", "db"]
}

data "tls_public_key" "deployment_ssh_key" {
  private_key_openssh =  file("../config/private_key.pem")
}

resource "exoscale_ssh_key" "deployment_ssh_key" {
  name       = "kamal-deployment-ssh-key"
  public_key = data.tls_public_key.deployment_ssh_key.public_key_openssh
}

data "exoscale_template" "ubuntu_template" {
  zone = "ch-gva-2"
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

resource "exoscale_security_group" "voting-http" {
  name = "voting-http"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.voting-http.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.voting-http.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

resource "exoscale_security_group" "voting-ssh" {
  name = "voting-ssh"
}

resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.voting-ssh.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

resource "exoscale_security_group" "voting-ping" {
  name = "voting-ping"
}

resource "exoscale_security_group_rule" "icmp" {
  security_group_id = exoscale_security_group.voting-ping.id
  type              = "INGRESS"
  protocol          = "ICMP"
  cidr              = "0.0.0.0/0"
  icmp_code         = 0
  icmp_type         = 8
}

resource "exoscale_compute_instance" "small-instance" {
  zone     = "ch-gva-2"
  for_each = toset(var.server_names)
  name     = each.key

  template_id = data.exoscale_template.ubuntu_template.id
  type        = "standard.small"
  disk_size   = 10
  ssh_key     = exoscale_ssh_key.deployment_ssh_key.name
  security_group_ids = [
    exoscale_security_group.voting-http.id,
    exoscale_security_group.voting-ssh.id,
    exoscale_security_group.voting-ping.id]
}

# resource "exoscale_domain" "deployment_domain" {
#   name = "kamal-playground.ch"
# }

# resource "exoscale_domain_record" "web" {
#   domain      = exoscale_domain.deployment_domain.id
#   name        = "web"
#   record_type = "A"
#   content     = exoscale_compute_instance.small-instance["web"].public_ip_address
# }

# resource "exoscale_domain_record" "alias" {
#   domain      = exoscale_domain.deployment_domain.id
#   name        = "voting"
#   record_type = "CNAME"
#   content     = exoscale_domain_record.web.hostname
# }
