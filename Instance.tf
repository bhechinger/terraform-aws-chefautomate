data template_file "getssl_cfg" {
  template = "${file("${path.module}/files/getssl.cfg")}"

  vars {
    email    = "${var.getssl_email}"
    san_list = "${var.san_list}"
    fqdn     = "${var.fqdn}"
    ca       = "${local.ca}"
  }
}

data "template_file" "ChefServer_setup_script" {
  template = "${file("${path.module}/files/ChefServer.setup.sh")}"

  vars {
    fqdn              = "${var.fqdn}"
    admin_user        = "${var.admin_user}"
    admin_fn          = "${var.admin_firstname}"
    admin_ln          = "${var.admin_lastname}"
    admin_email       = "${var.admin_email}"
    org               = "${lower(var.chef_organization)}"
    admin_password    = "${var.admin_password}"
    access_key_id     = "${var.aws_access_key_id}"
    secret_access_key = "${var.aws_secret_access_key}"
    region            = "${local.region}"
  }
}

resource "aws_instance" "ChefServer" {
  ami           = "${local.ami}"
  instance_type = "${var.instance_type}"

  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]

  subnet_id = "${var.subnet_id}"
  key_name  = "${var.key_name}"

  root_block_device {
    volume_size = "${var.volume_size}"
    volume_type = "${var.volume_type}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/terraform/.getssl/${var.fqdn}",
    ]

    connection {
      type        = "ssh"
      host        = "${self.private_ip}"
      user        = "ec2-user"
      private_key = "${var.ssh_key}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.getssl_cfg.rendered}"
    destination = "/tmp/terraform/.getssl/${var.fqdn}/getssl.cfg"

    connection {
      type        = "ssh"
      host        = "${self.private_ip}"
      user        = "ec2-user"
      private_key = "${var.ssh_key}"
    }
  }

  provisioner "file" {
    content     = "${var.account_key}"
    destination = "/tmp/terraform/.getssl/account.key"

    connection {
      type        = "ssh"
      host        = "${self.private_ip}"
      user        = "ec2-user"
      private_key = "${var.ssh_key}"
    }
  }

  provisioner "file" {
    source      = "${path.module}/files/dns_route53.py"
    destination = "/tmp/terraform/dns_add_route53"

    connection {
      type        = "ssh"
      host        = "${self.private_ip}"
      user        = "ec2-user"
      private_key = "${var.ssh_key}"
    }
  }

  provisioner "remote-exec" {
    inline = "${data.template_file.ChefServer_setup_script.rendered}"

    connection {
      type        = "ssh"
      host        = "${self.private_ip}"
      user        = "ec2-user"
      private_key = "${var.ssh_key}"
    }
  }

  tags {
    Name = "${var.fqdn}"
  }
}
