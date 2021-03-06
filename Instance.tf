data template_file "getssl_cfg" {
  template = "${file("${path.module}/files/getssl.cfg")}"

  vars {
    email    = "${var.getssl_email}"
    san_list = "${var.san_list}"
    fqdn     = "${lower(var.fqdn)}"
    ca       = "${var.prod_ca ? local.prod_ca : local.stage_ca}"
  }
}

data "template_file" "ChefServer_setup_script" {
  template = "${file("${path.module}/files/ChefServer.setup.sh")}"

  vars {
    fqdn             = "${lower(var.fqdn)}"
    admin_user       = "${var.admin_user}"
    admin_fn         = "${var.admin_firstname}"
    admin_ln         = "${var.admin_lastname}"
    admin_email      = "${var.admin_email}"
    org              = "${lower(var.chef_organization)}"
    enterprise       = "${var.automate_enterprise}"
    admin_password   = "${var.admin_password}"
    region           = "${local.region}"
    upgrade_chef     = "${var.upgrade_chef}"
    enable_telemetry = "${var.enable_telemetry}"
    region           = "${local.region}"
    bucket_name      = "${var.bucket_name}"
  }
}

data "template_file" "aws_credentials" {
  template = "${file("${path.module}/files/aws_credentials")}"

  vars {
    access_key_id     = "${var.aws_access_key_id}"
    secret_access_key = "${var.aws_secret_access_key}"
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
      "mkdir -p /tmp/terraform/.getssl/${lower(var.fqdn)}",
    ]

    connection {
      type        = "ssh"
      host        = "${self.private_ip}"
      user        = "ec2-user"
      private_key = "${var.ssh_key}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.aws_credentials.rendered}"
    destination = "/tmp/terraform/aws_credentials"

    connection {
      type        = "ssh"
      host        = "${self.private_ip}"
      user        = "ec2-user"
      private_key = "${var.ssh_key}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.getssl_cfg.rendered}"
    destination = "/tmp/terraform/.getssl/${lower(var.fqdn)}/getssl.cfg"

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
    destination = "/tmp/terraform/dns_route53.py"

    connection {
      type        = "ssh"
      host        = "${self.private_ip}"
      user        = "ec2-user"
      private_key = "${var.ssh_key}"
    }
  }

  provisioner "file" {
    source      = "${path.module}/files/s3_upload.py"
    destination = "/tmp/terraform/s3_upload.py"

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

  tags = "${var.tags}"
}
