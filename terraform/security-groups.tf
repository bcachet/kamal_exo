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
