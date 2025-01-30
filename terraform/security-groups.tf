resource "exoscale_security_group" "web" {
  name = "web"
}

resource "exoscale_security_group_rule" "web-http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

resource "exoscale_security_group_rule" "web-https" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

resource "exoscale_security_group_rule" "web-ssh" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

resource "exoscale_security_group_rule" "web-icmp" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "ICMP"
  cidr              = "0.0.0.0/0"
  icmp_code         = 0
  icmp_type         = 8
}

resource "exoscale_security_group" "db" {
  name = "db"
}

resource "exoscale_security_group_rule" "db-redis" {
  security_group_id      = exoscale_security_group.db.id
  type                   = "INGRESS"
  protocol               = "TCP"
  user_security_group_id = exoscale_security_group.web.id
  start_port             = 6379
  end_port               = 6379
}

resource "exoscale_security_group_rule" "db-ssh" {
  security_group_id = exoscale_security_group.db.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}
