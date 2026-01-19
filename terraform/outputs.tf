output "bastion_public_ip" {
  description = "IP publique du bastion"
  value       = outscale_public_ip.bastion.public_ip
}

output "web_private_ips" {
  description = "IPs privées des serveurs web"
  value       = outscale_vm.web[*].private_ip
}

output "load_balancer_dns" {
  description = "DNS du Load Balancer"
  value       = outscale_load_balancer.web_lb.dns_name
}

output "ssh_key_path" {
  description = "Chemin vers la clé SSH privée"
  value       = local_file.private_key.filename
}

output "ssh_bastion_command" {
  description = "Commande pour se connecter au bastion"
  value       = "ssh -i ${local_file.private_key.filename} outscale@${outscale_public_ip.bastion.public_ip}"
}

output "ssh_web_command" {
  description = "Commande pour se connecter aux serveurs web via le bastion"
  value       = [
    for ip in outscale_vm.web[*].private_ip :
    "ssh -i ${local_file.private_key.filename} -J outscale@${outscale_public_ip.bastion.public_ip} outscale@${ip}"
  ]
}