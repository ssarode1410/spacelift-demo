# Terraform & Ansible Orchestration via Jenkins

## 🚀 Overview
This project is a Proof of Concept (PoC) demonstrating how to seamlessly orchestrate Infrastructure as Code (Terraform) and Configuration Management (Ansible) using a standard **Jenkins CI/CD Pipeline**. 

It was inspired by a tutorial demonstrating this workflow in Spacelift, but re-engineered here to rely entirely on open-source tools and custom shell scripting for dynamic inventory management.

## 🏗️ Architecture & Workflow

1. **Checkout:** Jenkins pulls the latest infrastructure code from this repository.
2. **Provision (Terraform):** The pipeline initializes and applies the Terraform configuration to provision an AWS EC2 instance fleet.
3. **The Hook (Dynamic Inventory):** The pipeline uses `jq` to parse the `terraform output` (extracting the raw public IPs of the newly created instances) and dynamically generates an `inventory.ini` file for Ansible.
4. **Configure (Ansible):** Jenkins securely binds SSH credentials and triggers the Ansible playbook (`install_htop.yaml`) to target the dynamically generated inventory, configuring the servers immutably. 

## 🛠️ Prerequisites
To run this pipeline, the Jenkins server (or agent) requires the following installed in its `$PATH`:
* **Terraform**
* **Ansible**
* **AWS CLI** (Configured with appropriate IAM permissions)
* **jq** (Command-line JSON processor)

### Jenkins Configuration
The pipeline expects the following credentials to be securely stored in the Jenkins Global Credentials vault:
* `aws-access-key-id` (Secret Text)
* `aws-secret-access-key` (Secret Text)
* `ansible-ssh-key` (SSH Username with Private Key - *using ed25519*)

## 💡 Key Features
* **Idempotency:** The pipeline can be run repeatedly safely. Terraform manages the state, and Ansible ensures configurations are only applied when necessary.
* **No Hardcoded Secrets:** All AWS credentials and SSH keys are injected at runtime via the Jenkins `withCredentials` block.
* **Zero-Touch Scaling:** Simply add a new instance to the `locals` block in `main.tf`. On the next build, Terraform will provision *only* the new instance, and Ansible will configure *only* the new instance.

## 📂 Repository Structure
* `/tf/` - Contains the Terraform configuration files (`main.tf`, `outputs.tf`, `variables.tf`).
* `/ansible/` - Contains the Ansible playbooks (`install_htop.yaml`).
* `Jenkinsfile` - The declarative pipeline script that ties the tools together. (Note: Ensure this is added to your repo if it isn't already!)
