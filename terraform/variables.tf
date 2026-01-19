# Credentials
variable "access_key_id" {
  description = "OUTSCALE Access Key"
  type        = string
  sensitive   = true
}

variable "secret_key_id" {
  description = "OUTSCALE Secret Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "OUTSCALE Region"
  type        = string
  default     = "eu-west-2"
}

# Réseau
variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block pour le subnet public"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block pour le subnet privé"
  type        = string
  default     = "10.0.2.0/24"
}

# Instance
variable "bastion_type" {
  description = "Type d'instance pour le bastion"
  type        = string
  default     = "tinav2.c1r1p3"
}

variable "web_type" {
  description = "Type d'instance pour les serveurs web"
  type        = string
  default     = "tinav2.c1r1p3"
}

variable "instance_count" {
  description = "Nombre de serveurs web"
  type        = number
  default     = 2
}

# Tags
variable "project_name" {
  description = "Nom du projet pour les tags"
  type        = string
  default     = "cloud-infra"
}

# Image
variable "image_id" {
  description = "ID de l'image Ubuntu"
  type        = string
  default     = "ami-7b8d1702"  # Ubuntu Server 22.04 LTS
}