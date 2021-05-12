output "eip_address" {
  value = "${aws_eip.lb.public_ip}"
}

output "aws_webserver_id" {
  value = "${aws_instance.webserver.id}"
}

output "aws_sg_allow_web_ssh_id" {
  value = "${aws_security_group.allow_web_ssh.id}"
}