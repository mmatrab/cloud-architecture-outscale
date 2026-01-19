# Configuration du Load Balancer
resource "outscale_load_balancer" "web_lb" {
  load_balancer_name = "${var.project_name}-lb"
  subnets           = [outscale_subnet.public.subnet_id]
  security_groups   = [outscale_security_group.lb.security_group_id]
  
  listeners {
    backend_port           = 80
    backend_protocol       = "HTTP"
    load_balancer_port     = 80
    load_balancer_protocol = "HTTP"
  }

  tags {
    key   = "Name"
    value = "${var.project_name}-lb"
  }
}

# Configuration du Load Balancer pour les VMs
resource "outscale_load_balancer_vms" "web_lb_registration" {
  load_balancer_name = outscale_load_balancer.web_lb.load_balancer_name
  backend_vm_ids     = outscale_vm.web[*].vm_id
}

# Health Check Configuration
resource "outscale_load_balancer_attributes" "web_lb_health_check" {
  load_balancer_name = outscale_load_balancer.web_lb.load_balancer_name
  
  health_check {
    check_interval     = 5
    healthy_threshold   = 5
    path               = "/"
    port               = 80
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }
}