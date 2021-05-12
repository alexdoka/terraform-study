variable region {
  default = "eu-central-1"
}

variable cidr_block {
  default = "10.14.0.0/16"
}

variable public-net-ranges {
  type = list
  default = [
    "10.14.1.0/24",
    "10.14.2.0/24"
  ]
}

variable private-net-ranges {
  type = list
  default = [
    "10.14.11.0/24",
    "10.14.22.0/24"
  ]
}

