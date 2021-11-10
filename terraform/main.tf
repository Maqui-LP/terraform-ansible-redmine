terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.64"
    }
  }
}

  provider "aws" {
    profile = "default"
    region = "us-east-1"
  }

variable "root_db_pass" {
  type = string
  default = "root"
}

variable "redmine_db_pass" {
  type = string
  default = "password"
}

resource "aws_ebs_volume" "ebs"{
  availability_zone =  aws_instance.redmine_app.availability_zone
  size              = 8
  
  tags = {
    Name = "Redmine"
    Environment = "Production"
  }
}

# Aca tengo que poner el backup y me tengo que conectar usando ssh
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = aws_instance.redmine_app.id
  
  connection {
    type = "ssh"
    user = "ubuntu"
    #password no, private key
    private_key = "./mpoisson.pem" 
  }
}

resource "aws_security_group" "redmine_sg" {
  name = "ssh_http_https"
  #SSH
  ingress {  
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  #HTTP
  ingress {  
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  #HTTPS
  ingress {  
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  #Outbound --> allow all
  egress  {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "redmine_app" {
  ami           = "ami-0279c3b3186e54acd" #Ubuntu 18.04
  instance_type = "t2.micro"
  security_groups = [ "redmine_sg" ]
  key_name = "mpoisson"


provisioner "local-exec" {                                                    #No va la literal, no?
  command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i ${aws_instance.redmine_app.public_ip} --private-key ./mpoisson.pem /provisioning/playbook.yml --extra-vars root_db_pass=${var.root_db_pass} redmine_db_pass=${var.redmine_db_pass}"
  
  }
    
  tags = {
    Name = "Redmine"
    Environment = "Production"
  }
}