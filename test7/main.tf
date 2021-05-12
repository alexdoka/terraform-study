// create vpc
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "custom_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "custom-igw"
  }
}

data "aws_availability_zones" "list" {}


// create public networks with internet access
resource "aws_subnet" "public" {
  count                   = length(var.public-net-ranges)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public-net-ranges[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.list.names[count.index]
  tags = {
    Name = "public-network ${count.index + 1}"
  }
}

// create route table
resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "internet access"
  }
}


resource "aws_route_table_association" "publ" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.r.id
}

// create private networks
resource "aws_subnet" "private" {
  count                   = length(var.private-net-ranges)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private-net-ranges[count.index]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.list.names[count.index]
  tags = {
    Name = "private-network ${count.index + 1}"
  }
}

resource "aws_eip" "natip" {
  count = length(aws_subnet.private)
}


resource "aws_nat_gateway" "natgw" {
  count         = length(aws_subnet.private)
  allocation_id = aws_eip.natip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "nat gw for privet net ${count.index}"
  }
}


// create route table for private nets
resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }

  tags = {
    Name = "nat internet access"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private[*].id)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

// aws instances
resource "aws_key_pair" "dokapubkey" {
  key_name   = "dokakey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHLHRe4dkwXZj8QMEkHVTlhUXvdlwKrac3EwTTz9pTPqdxQXnvOxTfQ2ClBcjxzqqJ92bTl8GjXDR06lI8M4vMag1UPZiDqA3cZbEJ0lbepzmAzZA06pj3dWUtBWk2SvNovJdQEIC1WBGm53MzLUTDx7whuPa97VAqjtIP51RxAsM12vcr0DyNPkYZxbGkfk17ceC17gv+yb0xH5iTmDabUG8zM+7NZvbB+BT509Wef7HeLXQUobmkPRMTBieXRgtjcZDb+Kk4JvHDtjHC5+gQ5iwkLj5Z46FWU/Ugz9ezcIGat4FufT4Fh8t49UTzAwZvAiXKS/DKGwebqLbxP5jL doka@doka-ubuntu3"
}


resource "aws_security_group" "custom_sg" {
  name        = "allow_cust_ports"
  description = "allow_cust_ports"
  vpc_id      = aws_vpc.main.id


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


#  // create launch config

data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

resource "aws_launch_configuration" "in_publ" {
  name_prefix   = "terraform-lc-public-"
  image_id      = data.aws_ami.amazon.id
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "in_publ" {
  name_prefix          = "terraform-asg-public-"
  launch_configuration = aws_launch_configuration.in_publ.name
  vpc_zone_identifier = aws_subnet.public[*].id
  min_size             = 3
  max_size             = 3

  lifecycle {
    create_before_destroy = true
  }
}







# data "aws_ami" "amazon" {
#   most_recent = true
#   owners      = ["137112412989"]
#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
#   }
# }

# resource "aws_instance" "web" {
#   ami                    = data.aws_ami.amazon.id
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.public[0].id
#   vpc_security_group_ids = [aws_security_group.custom_sg.id]
#   key_name               = "dokakey"

#   tags = {
#     Name = "HelloWorld"
#   }
# }

# resource "aws_instance" "web2" {
#   ami                    = data.aws_ami.amazon.id
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.private[0].id
#   vpc_security_group_ids = [aws_security_group.custom_sg.id]
#   key_name               = "dokakey"

#   tags = {
#     Name = "HelloWorld2"
#   }
# }

