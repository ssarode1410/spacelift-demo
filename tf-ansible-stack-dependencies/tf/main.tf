provider "aws" {
  region = "eu-west-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["099720109477"] #canonical
}

locals {
  instances = {
    instance1 = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t2.micro"
    }
    instance2 = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t2.micro"
    }
    instance3 = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t2.micro"
    }
    instance4 = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t2.micro"
    }
    instance5 = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t2.micro"
    }
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ansible-ed25519-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIyZVA9HAxeWaKZaPsvq1N8I9umnkoUtOHBoAr+2XH+X shantanu@Shantanu"
}

# =======================================================
# NEW: Security Group to open monitoring ports
# =======================================================
resource "aws_security_group" "observability_sg" {
  name        = "observability_sg"
  description = "Allow inbound traffic for SSH, Prometheus, Node Exporter, and Grafana"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana Dashboard"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  for_each                    = local.instances
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  
  # =======================================================
  # NEW: Attach the Security Group to your instances
  # =======================================================
  vpc_security_group_ids      = [aws_security_group.observability_sg.id]

  tags = {
    Name = each.key
  }
}
