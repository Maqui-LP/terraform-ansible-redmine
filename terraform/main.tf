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
  region  = "us-east-1"
}

variable "root_db_pass" {
  type    = string
  default = "rootpass"
}

variable "redmine_db_pass" {
  type    = string
  default = "password"
}

variable "use_externalDB" {
  type    = string
  default = "true"
}

resource "aws_db_instance" "redmine-db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  parameter_group_name = "default.mysql8.0"
  username             = "root"
  password             = var.root_db_pass
  skip_final_snapshot  = true

  tags = {
    Name        = "Redmine"
    Environment = "Production"
  }

}

resource "aws_ebs_volume" "ebs" {
  availability_zone = aws_instance.redmine_app.availability_zone
  size              = 8

  tags = {
    Name        = "Redmine"
    Environment = "Production"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = aws_instance.redmine_app.id

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./mpoisson.pem")
    host        = aws_instance.redmine_app.public_ip
  }
}

resource "aws_instance" "redmine_app" {
  ami             = "ami-0279c3b3186e54acd" #Ubuntu 18.04
  instance_type   = "t2.micro"
  security_groups = ["redmine"]
  key_name        = "mpoisson"

  provisioner "remote-exec" {
    inline = ["echo 'Waiting till SSH is ready' "]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./mpoisson.pem")
      host        = aws_instance.redmine_app.public_ip
    }
  }
#Esto ponerlo en un null resource y null provisioners
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ./mpoisson.pem -i '${aws_instance.redmine_app.public_ip}', ../provisioning/playbook.yml --extra-vars 'root_db_pass=${var.root_db_pass} redmine_db_pass=${var.redmine_db_pass} db_host=${aws_db_instance.redmine-db.address} use_externalDB=${var.use_externalDB}'"

  }

  tags = {
    Name        = "Redmine"
    Environment = "Production"
  }
}

output "redmine_app_ip" {
  value = aws_instance.redmine_app.public_ip
}
output "redmine_db_ip" {
  value = aws_db_instance.redmine-db.address
}
