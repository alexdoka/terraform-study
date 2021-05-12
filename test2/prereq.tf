resource "aws_key_pair" "dokapubkey" {
  key_name   = "dokakey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHLHRe4dkwXZj8QMEkHVTlhUXvdlwKrac3EwTTz9pTPqdxQXnvOxTfQ2ClBcjxzqqJ92bTl8GjXDR06lI8M4vMag1UPZiDqA3cZbEJ0lbepzmAzZA06pj3dWUtBWk2SvNovJdQEIC1WBGm53MzLUTDx7whuPa97VAqjtIP51RxAsM12vcr0DyNPkYZxbGkfk17ceC17gv+yb0xH5iTmDabUG8zM+7NZvbB+BT509Wef7HeLXQUobmkPRMTBieXRgtjcZDb+Kk4JvHDtjHC5+gQ5iwkLj5Z46FWU/Ugz9ezcIGat4FufT4Fh8t49UTzAwZvAiXKS/DKGwebqLbxP5jL doka@doka-ubuntu3"
}


resource "aws_security_group" "allow_web_ssh" {
  name        = "allow_web_ssh"
  description = "Allow web and ssh"
  
  ingress {
    description = "allow 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow 22"
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
    Name = "MyWebserver"
  }
}
