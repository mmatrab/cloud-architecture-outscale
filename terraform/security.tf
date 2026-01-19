# Groupe de sécurité pour le bastion
resource "outscale_security_group" "bastion" {
  description         = "Security group for bastion host"
  security_group_name = "${var.project_name}-bastion-sg"
  net_id             = outscale_net.main.net_id
  
  tags {
    key   = "Name"
    value = "${var.project_name}-bastion-sg"
  }
}

# Règles pour le bastion
resource "outscale_security_group_rule" "bastion_ssh" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.bastion.security_group_id
  from_port_range   = "22"
  to_port_range     = "22"
  ip_protocol       = "tcp"
  ip_range          = "0.0.0.0/0"
}

# Groupe de sécurité pour les serveurs web
resource "outscale_security_group" "web" {
  description         = "Security group for web servers"
  security_group_name = "${var.project_name}-web-sg"
  net_id             = outscale_net.main.net_id
  
  tags {
    key   = "Name"
    value = "${var.project_name}-web-sg"
  }
}

# Règles pour les serveurs web - SSH depuis le subnet public
resource "outscale_security_group_rule" "web_ssh_from_bastion" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.web.security_group_id
  from_port_range   = "22"
  to_port_range     = "22"
  ip_protocol       = "tcp"
  ip_range          = var.public_subnet_cidr
}

# Règles pour les serveurs web - HTTP
resource "outscale_security_group_rule" "web_http" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.web.security_group_id
  from_port_range   = "80"
  to_port_range     = "80"
  ip_protocol       = "tcp"
  ip_range          = "0.0.0.0/0"
}

# Groupe de sécurité pour le load balancer
resource "outscale_security_group" "lb" {
  description         = "Security group for load balancer"
  security_group_name = "${var.project_name}-lb-sg"
  net_id             = outscale_net.main.net_id
  
  tags {
    key   = "Name"
    value = "${var.project_name}-lb-sg"
  }
}

# Règles pour le load balancer - HTTP
resource "outscale_security_group_rule" "lb_http" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.lb.security_group_id
  from_port_range   = "80"
  to_port_range     = "80"
  ip_protocol       = "tcp"
  ip_range          = "0.0.0.0/0"
}