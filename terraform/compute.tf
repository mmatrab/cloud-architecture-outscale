# Génération de la clé SSH
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Sauvegarde de la clé privée localement
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/ssh_key.pem"
  file_permission = "0600"
}

# Création de la keypair OUTSCALE
resource "outscale_keypair" "deployer" {
  keypair_name = "${var.project_name}-keypair"
  public_key   = tls_private_key.ssh_key.public_key_openssh
}

# Instance Bastion
resource "outscale_vm" "bastion" {
  image_id           = var.image_id
  vm_type           = var.bastion_type
  keypair_name      = outscale_keypair.deployer.keypair_name
  security_group_ids = [outscale_security_group.bastion.security_group_id]
  subnet_id         = outscale_subnet.public.subnet_id

  tags {
    key   = "Name"
    value = "${var.project_name}-bastion"
  }
}

# IP Publique pour le Bastion
resource "outscale_public_ip" "bastion" {
  tags {
    key   = "Name"
    value = "${var.project_name}-bastion-ip"
  }
}

resource "outscale_public_ip_link" "bastion" {
  public_ip = outscale_public_ip.bastion.public_ip
  vm_id     = outscale_vm.bastion.vm_id
}

# Serveurs Web
resource "outscale_vm" "web" {
  count             = var.instance_count
  image_id           = var.image_id
  vm_type           = var.web_type
  keypair_name      = outscale_keypair.deployer.keypair_name
  security_group_ids = [outscale_security_group.web.security_group_id]
  subnet_id         = outscale_subnet.private.subnet_id

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              echo "<h1>Serveur Web ${count.index + 1}</h1>" > /var/www/html/index.html
              echo "<p>Hostname: $(hostname)</p>" >> /var/www/html/index.html
              systemctl enable apache2
              systemctl start apache2
              EOF
  )

  tags {
    key   = "Name"
    value = "${var.project_name}-web-${count.index + 1}"
  }
}