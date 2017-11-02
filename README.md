# terraform-aws-chefautomate
Terraform Module for deploying Chef Automate from the Marketplace

No real docs, just this crappy example:

```
module "ChefServer" {
  source    = "github.com/bhechinger/terraform-aws-chefautomate"
  key_name  = "YourEC2KeyNameHere"
  ssh_key   = "${file("keys/YourEC2PrivateKeyHere.pem")}"
  fqdn      = "ThisIsTheName.youworkhere.com"
  subnet_id = "${element(module.vars.private_subnet, 0)}"
   
  vpc_security_group_ids = [
    "${aws_security_group.Webserver.id}",
    "${aws_security_group.SSH.id}",
    "${aws_security_group.ICMP.id}",
    "${aws_security_group.ChefServer.id}",
  ]
   
  admin_user          = "myadmin"
  admin_firstname     = "YouWorkHere"
  admin_lastname      = "Admin"
  admin_password      = "SooperDooperSecretPassword"
  admin_email         = "you@youworkhere.com"
  chef_organization   = "youworkhere"
  automate_enterprise = "youworkhere"
   
  getssl_email          = "you@youworkhere.com"
  account_key           = "${file("files/account.key")}"
  san_list              = "chef.youworkhere.com"
  aws_access_key_id     = "LLSKDFJHLSKDJFHLSDKFJj"
  aws_secret_access_key = "LKJHDSFO(*&Y#$LKJHDF"
  prod_ca               = true
   
  tags = {
    Name        = "ChefServer"
    Environment = "Infrastructure"
  }
}
   
resource "aws_route53_record" "ChefServer" {
  name    = "${module.ChefServer.fqdn}"
  type    = "A"
  ttl     = "300"
  zone_id = "${module.vars.dns_internal_zone}"
  records = ["${module.ChefServer.private_ip}"]
}
```