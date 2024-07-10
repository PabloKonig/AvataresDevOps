terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Determinación de la región de AWS donde se crean los recursos.
}

# Configuración del grupo de seguridad para permitir el tráfico HTTP y SSH.

resource "aws_security_group" "permitir_http_ssh" {
  name = "permitir_http_ssh"
  description = "Permite el trafico HTTP y SSH"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite el acceso SSH desde cualquier lugar.
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Permite el acceso HTTP desde cualquier lugar.
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Permite la salida de información.
  }
}

# Crear una instancia EC2 para Minikube

resource "aws_instance" "minikube_instance" {
  ami           = "ami-04a81a99f5ec58529"           #AMI de Ubuntu 20.04 LTS para us-east-1
  instance_type = "t3.medium" 
  key_name      = "avatares"  # Clave SSH usada en el proyecto.
  vpc_security_group_ids = [aws_security_group.permitir_http_ssh.id]
  
  tags = {
    Name = "minikube-instance"
  }
  
  provisioner "local-exec" {
    command = "echo \"La IP pública de la instancia es: ${aws_instance.minikube_instance.public_ip}\""
  }

  user_data = <<-EOF
#!/bin/bash
  sudo apt update
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  chmod +x minikube-linux-amd64
  sudo mv minikube-linux-amd64 /usr/local/bin/minikube

  # Instalar Docker
  sudo apt install -y docker.io
  sudo systemctl start docker
  sudo systemctl enable docker 
  
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  sudo usermod -aG docker $USER && newgrp docker
  sudo minikube start --driver=docker --force

EOF
}