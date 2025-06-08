# AWS Compute Automation Using Terraform
This project is a Terraform configuration for provisioning a basic AWS environment to run a virtual machine (EC2 instance) using infrastructure as code.

# What it does
Creates a VPC: Sets up a custom Virtual Private Cloud for network isolation.

Creates a Subnet: Defines a subnet within the VPC.

Attaches an Internet Gateway: Allows resources in the subnet to access the internet.

Configures Route Tables: Ensures traffic can route from the subnet to the internet.

Creates Security Groups:

One for SSH (port 22) access.

One for HTTP (port 80) access.

Fetches a Debian AMI: Dynamically finds the latest Debian 11 image for EC2.

Creates an EC2 Key Pair: Uses your SSH public key for secure login.

Requests a Spot Instance: Launches a cost-effective EC2 instance using the above resources.

Outputs the Public IP: So you can SSH into your new VM.

# How it works
You set your AWS credentials and SSH public key path in .envrc.
Terraform uses these variables to provision all resources in AWS.
After terraform apply, you get a running Debian VM accessible via SSH.

# Summary:
This project automates the setup of a secure, internet-accessible Debian VM on AWS using Terraform.
