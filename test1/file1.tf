resource "aws_instance" "web" {
  count           = 1
  ami             = "ami-05ca073a83ad2f28c"
  instance_type   = "t2.micro"
  key_name        = "deployer-key"
  security_groups = ["allow_ssh"]
  tags = {
    Name = "HelloWorld"
  }

  provisioner "file" {
    source      = "./sss.sh"
    destination = "/tmp/sss.sh"
  }

  # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/sss.sh",
      "sudo /tmp/sss.sh",
    ]
  }

  # Login to the ec2-user with the aws key.
  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    = ""
    private_key = file("/home/doka/.ssh/id_rsa")
    host        = self.public_ip
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHLHRe4dkwXZj8QMEkHVTlhUXvdlwKrac3EwTTz9pTPqdxQXnvOxTfQ2ClBcjxzqqJ92bTl8GjXDR06lI8M4vMag1UPZiDqA3cZbEJ0lbepzmAzZA06pj3dWUtBWk2SvNovJdQEIC1WBGm53MzLUTDx7whuPa97VAqjtIP51RxAsM12vcr0DyNPkYZxbGkfk17ceC17gv+yb0xH5iTmDabUG8zM+7NZvbB+BT509Wef7HeLXQUobmkPRMTBieXRgtjcZDb+Kk4JvHDtjHC5+gQ5iwkLj5Z46FWU/Ugz9ezcIGat4FufT4Fh8t49UTzAwZvAiXKS/DKGwebqLbxP5jL doka@doka-ubuntu3"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"

  ingress {
    description = "ssh from "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh"
  }
}
