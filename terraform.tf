variable "access_key" {}
variable "secret_key" {}
variable "region" {
	default = "us-east-1"
}
variable "instance_type" {}
variable "ami" {}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "debugging" {
    key_name = "tmp-key"
    public_key = "${file("ssh_keys/tmp-key.pub")}"
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
    description = "Allow ssh connections on port 22"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
	  from_port = 0
	  to_port = 0
	  protocol = "-1"
	  cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  count = 1
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  key_name = "${aws_key_pair.debugging.key_name}"
  
  provisioner "local-exec" {
	command = "echo ${aws_instance.app_server.public_ip} > ip_address.txt"
  }
  
  connection {
    user = "ubuntu"
	type =  "ssh"	
    private_key  = "${file("ssh_keys/tmp-key")}"
  }
    
  provisioner "local-exec" {
   command = "sleep 130 && echo  \"[webserver]\n${aws_instance.app_server.public_ip} ansible_connection=ssh ansible_ssh_user=ubuntu ansible_ssh_private_key_file=ssh_keys/tmp-key \" > inventory && ansible-playbook -i inventory playbook.yml"
  }

    

 



  
  
}

output "public_ip" {
	value = "${aws_instance.app_server.public_ip}"
  }


