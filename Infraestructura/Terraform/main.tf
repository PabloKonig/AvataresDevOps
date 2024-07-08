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
  description = "Permite el tráfico HTTP y SSH"

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
  ami           = "ami-0c55b31ad2299a701"           #AMI de Ubuntu 20.04 para us-east-1
  instance_type = "t2.micro" 
  key_name      = "tu_clave_ssh"  # Clave SSH usada en el proyecto.
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]

  tags = {
    Name = "minikube-instance"
  }
}