output "id" {
  value = "${aws_instance.ChefServer.id}"
}

output "private_ip" {
  value = "${aws_instance.ChefServer.private_ip}"
}

output "fqdn" {
  value = "${var.fqdn}"
}