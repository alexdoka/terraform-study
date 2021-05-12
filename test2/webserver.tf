
resource "aws_instance" "webserver" {
  ami             = "ami-00edb93a4d68784e3"
  key_name        = "dokakey"
  security_groups = ["allow_web_ssh"]
  instance_type   = "t2.micro"
  user_data = templatefile("./pattern.sh.tpl", {
    name1     = "Alex",
    name2     = "Doka",
    mylist = ["Generated", "from", "list"]
  })

  tags = {
    Name  = "TestWebserver"
    Owner = "Aliaksandr Dakutovich"
  }
}
