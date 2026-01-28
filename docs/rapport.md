# Cloud Infrastructure Documentation with Terraform

## Authors
| Name                                    | Contact                                            |
|-----------------------------------------|----------------------------------------------------|
| Mohamed Matrab                          | mohamed.matrab@epita.fr                            |

---

## Table of Contents
1. [Introduction](#introduction)
2. [Architecture](#architecture)
3. [Key Concepts](#key-concepts)
4. [Prerequisites](#prerequisites)
5. [Project Structure](#project-structure)
6. [Step-by-Step Guide](#step-by-step-guide)
7. [Tests and Validation](#tests-and-validation)
8. [Troubleshooting](#troubleshooting)
9. [Maintenance](#maintenance)

## Introduction
This project designed to deploy a secure cloud infrastructure on 3DS OUTSCALE using Terraform. The architecture includes a VPC with public and private subnets, a bastion host for secure SSH access, and redundant web servers behind a load balancer.

## Architecture

### Components
- **VPC (10.0.0.0/16)**
  - Public subnet (10.0.1.0/24)
  - Private subnet (10.0.2.0/24)
  - Internet Gateway
  - NAT Gateway

- **Instances**
  - Bastion (public subnet)
  - 2 web servers (private subnet)

- **Security**
  - Separate security groups for each component
  - SSH access only through the bastion
  - Load balancer to distribute web traffic

### Architecture Diagram
![Infrastructure Architecture](./mermaid-diagram.png)

## Key Concepts for Non-Specialists

### Core Components

#### VPC (Virtual Private Cloud)
  A VPC is like a private data center in the cloud. It is an isolated space where you can safely deploy resources—think of it as a secure building with multiple floors (subnets).

#### Subnets
Subnets are divisions of your VPC. This architecture uses two types:
  - **Public subnet**: Accessible from the Internet, like the building lobby
  - **Private subnet**: Protected from the Internet, like secured floors

#### Bastion Host
The bastion acts as the security guard. It is the only allowed entry point to reach your servers, enabling you to:
  - Centralize access
  - Strengthen security
  - Audit connections

#### Load Balancer
The load balancer is the traffic dispatcher. It:
  - Distributes visitors across multiple servers
  - Ensures high availability
  - Protects against overloads

### Security

#### Security Groups
They behave like virtual guards that:
  - Control who can access what
  - Define precise rules (who can talk to whom)
  - Protect each component individually

#### NAT Gateway
Lets private servers access the Internet without being exposed, acting as a trusted intermediary.

### High Availability

This architecture delivers high availability through:
  - Multiple web servers
  - Automatic traffic distribution
  - Continuous health checks

### Why This Architecture?

1. **Security**:
   - Web servers protected in the private network
   - Access controlled through the bastion
   - Traffic filtering at multiple layers

2. **Performance**:
   - Automatic load distribution
   - Adapts to traffic spikes
   - Optimized response time

3. **Maintainability**:
   - Centralized configuration with Terraform
   - Easier updates
   - Simplified monitoring

## Prerequisites

- Active 3DS OUTSCALE account
- OUTSCALE Access Key and Secret Key
- Terraform v1.0.0 or newer
- SSH client
- Ubuntu 22.04 or newer for instances

## Project Structure
```
project-root/
├── README.md
├── docs/
│   ├── rapport.md
│   └── mermaid-diagram.png
├── scripts/
│   └── install_web.sh
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── outputs.tf
    ├── providers.tf
    ├── network.tf
    ├── security.tf
    ├── compute.tf
    └── loadbalancer.tf
```

## Step-by-Step Guide

### First Use

1. **Prepare**
   ```bash
   # Copy the example file
   cp terraform.tfvars.example terraform.tfvars
   
   # Edit the file with your credentials
   nano terraform.tfvars
   ```

2. **Initialize**
   ```bash
   cd terraform
   terraform init
   ```
   This command downloads the required plugins.

3. **Review**
   ```bash
   terraform plan
   ```
   Review the resources that will be created.

4. **Deploy**
   ```bash
   terraform apply
   ```
   Confirm with "yes" when prompted.

### Deployment Verification

1. **Connect to the Bastion**
   ```bash
   # The exact command is provided in the outputs
   ssh -i ssh_key.pem outscale@<BASTION_IP>
   ```

2. **Test the Web Servers**
   ```bash
   # From the bastion
   ssh outscale@<WEB_SERVER_IP>
   
   # Check Apache
   systemctl status apache2
   ```

3. **Test the Load Balancer**
   - Open the load balancer URL in a browser
   - Refresh several times
   - Observe the alternation between servers

### Routine Maintenance

1. **Update the Infrastructure**
   ```bash
   # Apply modifications
   terraform apply
   ```

2. **Add Servers**
   - Update `instance_count` in terraform.tfvars
   - Run `terraform apply`

3. **Monitoring**
   - Check Apache logs
   - Watch load balancer health checks
   - Monitor network traffic

### Shutdown and Cleanup

1. **Destroy the Infrastructure**
   ```bash
   terraform destroy
   ```

2. **Local Cleanup**
   ```bash
   ./cleanup.sh
   ```

### Common Issue Resolution

1. **SSH Connection Error**
   - Check key permissions
   - Confirm the bastion is reachable
   - Verify security rules

2. **Web Server Unreachable**
   - Check Apache status
   - Verify security rules
   - Review logs

## Tests and Validation

### 1. SSH Access to the Bastion
```bash
# Configure the SSH key
chmod 400 ssh_key.pem

# Connect to the bastion
ssh -i ssh_key.pem outscale@<BASTION_IP>
```

### 2. Access to Web Servers
From the bastion:
```bash
# Key setup on the bastion
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa

# Connect to the web servers
ssh outscale@10.0.2.241  # Web Server 1
ssh outscale@10.0.2.23   # Web Server 2
```

### 3. Load Balancer Test
```bash
# Access the load balancer
curl http://<LOAD_BALANCER_DNS>

# Check load distribution
for i in {1..10}; do 
  curl -s http://<LOAD_BALANCER_DNS> | grep "Hostname"
  sleep 1
done
```

## Troubleshooting

### Common Problems

1. **SSH Access Issue**
   - Check key permissions (chmod 400)
   - Check security groups
   - Check network connectivity

2. **Web Server Unreachable**
   - Check Apache status: `systemctl status apache2`
   - Check logs: `sudo tail /var/log/apache2/error.log`
   - Check security rules

3. **Load Balancer**
   - Check instance registration
   - Check health checks
   - Check security rules

## Maintenance

### Infrastructure Updates
```bash
terraform plan    # Review changes
terraform apply   # Apply changes
```

### Cleanup
```bash
terraform destroy # Remove the entire infrastructure
```

### Backups
- Terraform state: keep terraform.tfstate
- SSH keys: back up ssh_key.pem

## Security Notes

- SSH keys are generated automatically
- SSH access only through the bastion
- Web servers stay in the private network
- Web traffic is filtered by the load balancer
