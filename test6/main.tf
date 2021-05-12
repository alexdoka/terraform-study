# ----------------------------------------------------------------------
# Network infrastracture -----------------------------------------------
# ----------------------------------------------------------------------


resource "aws_vpc" "vpc_for_vms" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "temp_for_vms"
  }
}

data "aws_availability_zones" "avail" {}

resource "aws_subnet" "net1" {
  vpc_id                  = "${local.cust_vpc_id}"
  map_public_ip_on_launch = true
  cidr_block              = "10.0.1.0/24"
  availability_zone_id    = data.aws_availability_zones.avail.zone_ids[0]
  tags = {
    Name = "net1"
  }
}

resource "aws_subnet" "net2" {
  vpc_id                  = "${local.cust_vpc_id}"
  map_public_ip_on_launch = true
  cidr_block              = "10.0.2.0/24"
  availability_zone_id    = data.aws_availability_zones.avail.zone_ids[1]
  tags = {
    Name = "net2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${local.cust_vpc_id}"

  tags = {
    Name = "IGW_for_vms "
  }
}


resource "aws_route_table" "r" {
  vpc_id = "${local.cust_vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "Custom_Route_Table"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = "${local.cust_vpc_id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_route_table_association" "net1" {
  subnet_id      = aws_subnet.net1.id
  route_table_id = aws_route_table.r.id
}

resource "aws_route_table_association" "net2" {
  subnet_id      = aws_subnet.net2.id
  route_table_id = aws_route_table.r.id
}

# ----------------------------------------------------------------------
# EC2-instances --------------------------------------------------------
# ----------------------------------------------------------------------

resource "aws_security_group" "custom_sg" {
  name        = "allow_cust_ports"
  description = "allow_cust_ports"
  vpc_id      = local.cust_vpc_id


  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      description = "for web servers ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_cust_ports"
  }
}


data "aws_ami" "amazon-latest" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "dokapubkey" {
  key_name   = "dokakey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHLHRe4dkwXZj8QMEkHVTlhUXvdlwKrac3EwTTz9pTPqdxQXnvOxTfQ2ClBcjxzqqJ92bTl8GjXDR06lI8M4vMag1UPZiDqA3cZbEJ0lbepzmAzZA06pj3dWUtBWk2SvNovJdQEIC1WBGm53MzLUTDx7whuPa97VAqjtIP51RxAsM12vcr0DyNPkYZxbGkfk17ceC17gv+yb0xH5iTmDabUG8zM+7NZvbB+BT509Wef7HeLXQUobmkPRMTBieXRgtjcZDb+Kk4JvHDtjHC5+gQ5iwkLj5Z46FWU/Ugz9ezcIGat4FufT4Fh8t49UTzAwZvAiXKS/DKGwebqLbxP5jL doka@doka-ubuntu3"
}


resource "aws_instance" "web1" {
  ami                    = "${data.aws_ami.amazon-latest.id}"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.net1.id
  key_name               = "dokakey"
  vpc_security_group_ids = [aws_security_group.custom_sg.id]
  user_data              = file("./deploy.sh")
  tags = {
    Name = "web1"
  }
}




