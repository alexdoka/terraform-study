#----------------------------------------------------------
# Create:
#    - Security Group for Web Server
#    - Launch Configuration with Auto AMI Lookup
#    - Auto Scaling Group using 2 Availability Zones
#    - Classic Load Balancer in 2 Availability Zones
#-----------------------------------------------------------

# Classic load balancer

resource "aws_elb" "elb_webs" {
  name               = "elb-webservers"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.allow_web_control.id]


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

}



# security group 
resource "aws_security_group" "allow_web_control" {
  name        = "allow_web_control"
  description = "allow_web_control"
  #vpc_id      = "${aws_vpc.main.id}"

  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
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
    Name = "web and control"
  }
}


#    - Launch Configuration with Auto AMI Lookup

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_subnet" "primary" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "secondary" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_key_pair" "dokapubkey" {
  key_name   = "dokakey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHLHRe4dkwXZj8QMEkHVTlhUXvdlwKrac3EwTTz9pTPqdxQXnvOxTfQ2ClBcjxzqqJ92bTl8GjXDR06lI8M4vMag1UPZiDqA3cZbEJ0lbepzmAzZA06pj3dWUtBWk2SvNovJdQEIC1WBGm53MzLUTDx7whuPa97VAqjtIP51RxAsM12vcr0DyNPkYZxbGkfk17ceC17gv+yb0xH5iTmDabUG8zM+7NZvbB+BT509Wef7HeLXQUobmkPRMTBieXRgtjcZDb+Kk4JvHDtjHC5+gQ5iwkLj5Z46FWU/Ugz9ezcIGat4FufT4Fh8t49UTzAwZvAiXKS/DKGwebqLbxP5jL doka@doka-ubuntu3"
}


data "aws_ami" "amazon_img_latest" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix     = "terraform-lc-"
  image_id        = "${data.aws_ami.amazon_img_latest.id}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.allow_web_control.id}"]
  key_name        = "dokakey"
  user_data       = file("./webdeploy.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "myservers" {
  name                 = "auto-scailing-gr-${aws_launch_configuration.as_conf.name}"
  launch_configuration = aws_launch_configuration.as_conf.id
  vpc_zone_identifier  = [aws_default_subnet.primary.id, aws_default_subnet.secondary.id]
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  load_balancers       = [aws_elb.elb_webs.name]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "web_cluster_target_tracking_policy" {
  name                      = "staging-web-cluster-target-tracking-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = "${aws_autoscaling_group.myservers.name}"
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "40"
  }
}

