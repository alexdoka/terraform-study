/*
output  "AZ" {
  value = "${data.aws_availability_zones.avail}"
}

output  "amazon_image" {
  value = "${data.aws_ami.amazon-latest.image_id}"
}
*/

output  "vpc_for_vms_info" {
  value = "${aws_vpc.vpc_for_vms}"
}

variable "region" {
  default = "eu-central-1"
}

output  "test" {
  value = var.region
}

