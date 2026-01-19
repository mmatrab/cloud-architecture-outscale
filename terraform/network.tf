# Création du VPC
resource "outscale_net" "main" {
  ip_range = var.vpc_cidr
  
  tags {
    key   = "Name"
    value = "${var.project_name}-vpc"
  }
}

# Création du subnet public
resource "outscale_subnet" "public" {
  net_id         = outscale_net.main.net_id
  ip_range       = var.public_subnet_cidr
  subregion_name = "${var.region}a"
  
  tags {
    key   = "Name"
    value = "${var.project_name}-public"
  }
}

# Création du subnet privé
resource "outscale_subnet" "private" {
  net_id         = outscale_net.main.net_id
  ip_range       = var.private_subnet_cidr
  subregion_name = "${var.region}a"
  
  tags {
    key   = "Name"
    value = "${var.project_name}-private"
  }
}

# Internet Gateway
resource "outscale_internet_service" "main" {
  tags {
    key   = "Name"
    value = "${var.project_name}-igw"
  }
}

resource "outscale_internet_service_link" "main" {
  internet_service_id = outscale_internet_service.main.internet_service_id
  net_id             = outscale_net.main.net_id
}

# NAT Gateway
resource "outscale_public_ip" "nat" {
  tags {
    key   = "Name"
    value = "${var.project_name}-nat-ip"
  }
}

resource "outscale_nat_service" "main" {
  subnet_id    = outscale_subnet.public.subnet_id
  public_ip_id = outscale_public_ip.nat.public_ip_id
  
  tags {
    key   = "Name"
    value = "${var.project_name}-nat"
  }
}

# Route Tables
resource "outscale_route_table" "public" {
  net_id = outscale_net.main.net_id
  
  tags {
    key   = "Name"
    value = "${var.project_name}-public-rt"
  }
}

resource "outscale_route" "public_internet" {
  destination_ip_range = "0.0.0.0/0"
  gateway_id          = outscale_internet_service.main.internet_service_id
  route_table_id      = outscale_route_table.public.route_table_id
}

resource "outscale_route_table_link" "public" {
  subnet_id      = outscale_subnet.public.subnet_id
  route_table_id = outscale_route_table.public.route_table_id
}

resource "outscale_route_table" "private" {
  net_id = outscale_net.main.net_id
  
  tags {
    key   = "Name"
    value = "${var.project_name}-private-rt"
  }
}

resource "outscale_route" "private_nat" {
  destination_ip_range = "0.0.0.0/0"
  nat_service_id      = outscale_nat_service.main.nat_service_id
  route_table_id      = outscale_route_table.private.route_table_id
}

resource "outscale_route_table_link" "private" {
  subnet_id      = outscale_subnet.private.subnet_id
  route_table_id = outscale_route_table.private.route_table_id
}