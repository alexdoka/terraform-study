data "aws_availability_zones" "az" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_ami" "ubuntu_latest" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_ami" "amazon_img_latest" {
  #owners      = ["099720109477"]
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}


# -------------------------------------------
output "amazon_image_id" {
  value = "${data.aws_ami.amazon_img_latest.id}"
}

output "ubuntu_image_id" {
  value = "${data.aws_ami.ubuntu_latest.id}"
}

output "region_name" {
  value = "${data.aws_region.current.name}"
}

output "region_description" {
  value = "${data.aws_region.current.description}"
}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "aws_aws_availability_zones_names" {
  value = data.aws_availability_zones.az.names
}

output "aws_aws_availability_zones_ids" {
  value = data.aws_availability_zones.az.zone_ids
}
