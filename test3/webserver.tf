resource "aws_eip" "lb" {
  instance = aws_instance.webserver.id
  vpc      = true
}



resource "aws_instance" "webserver" {
  ami                    = "ami-00edb93a4d68784e3"
  key_name               = "dokakey"
  vpc_security_group_ids = [aws_security_group.allow_web_ssh.id]
  instance_type          = "t2.micro"
  user_data = templatefile("./pattern.sh.tpl", {
    name1  = "Alex",
    name2  = "Doka",
    mylist = ["Generated", "from", "list"]
  })
  depends_on = [
    aws_instance.dbserver,
    aws_instance.appserver
  ]
  tags = {
    Name  = "TestWebserver"
    Owner = "Aliaksandr Dakutovich"
  }
}

resource "aws_instance" "appserver" {
  ami                    = "ami-00edb93a4d68784e3"
  key_name               = "dokakey"
  vpc_security_group_ids = [aws_security_group.allow_web_ssh.id]
  instance_type          = "t2.micro"
  depends_on = [
    aws_instance.dbserver
  ]
  tags = {
    Name  = "Appserver"
    Owner = "Aliaksandr Dakutovich"
  }
}

resource "aws_instance" "dbserver" {
  ami                    = "ami-00edb93a4d68784e3"
  key_name               = "dokakey"
  vpc_security_group_ids = [aws_security_group.allow_web_ssh.id]
  instance_type          = "t2.micro"

  tags = {
    Name  = "dbserver"
    Owner = "Aliaksandr Dakutovich"
  }
}
