data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.177.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "custom_vpc"
  }
}

resource "aws_subnet" "main" {
  count             = "${length(data.aws_availability_zones.available.names)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.177.${10 + count.index}.0/24"
  tags = {
    Name = "main_subnet.${10 + count.index}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "main"
  }
}




