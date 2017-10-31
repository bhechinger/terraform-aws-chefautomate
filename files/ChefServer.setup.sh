#!/bin/bash

echo 'Sleeping for a couple minutes to allow things to settle down first'
sleep 120

sudo mv /tmp/terraform/* /root/
sudo mv /tmp/terraform/.getssl/ /root/
sudo chmod 755 /root/dns_route53.py
sudo ln -s /root/dns_route53.py /root/dns_add_route53
sudo ln -s /root/dns_route53.py /root/dns_del_route53
sudo curl --silent -o /root/getssl https://raw.githubusercontent.com/srvrco/getssl/master/getssl
sudo chmod 755 /root/getssl

sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum update -y
sudo yum install -y python-pip
sudo pip install boto3

echo 'api_fqdn "${fqdn}"' | sudo tee -a /etc/chef-marketplace/marketplace.rb

echo 'export AWS_ACCESS_KEY_ID="${access_key_id}"' | sudo tee -a /root/aws_creds
echo 'export AWS_SECRET_ACCESS_KEY="${secret_access_key}"' | sudo tee -a /root/aws_creds
echo 'export AWS_DEFAULT_REGION="${region}"' | sudo tee -a /root/aws_creds
echo 'export AWS_REGION="${region}"' | sudo tee -a /root/aws_creds

sudo chef-server-ctl stop
sudo chef-marketplace-ctl hostname ${fqdn}
sudo chef-server-ctl reconfigure
sudo chef-server-ctl restart

if [ "${upgrade_chef}" == "true" ]; then
    sudo chef-marketplace-ctl upgrade -y
fi

sudo chef-server-ctl reconfigure
sudo automate-ctl reconfigure

sudo /root/getssl ${fqdn}
echo '/root/getssl -u -a -q' | sudo tee -a /etc/cron.daily/getssl

sudo chef-server-ctl user-create ${admin_user} ${admin_fn} ${admin_ln} ${admin_email} '${admin_password}' --filename /root/${admin_user}.pem
sudo chef-server-ctl org-create ${org} 'Endotronix' --filename /root/${admin_user}-validator.pem -a ${admin_user}

if [ "${enterprise}" != "default" ]; then
    sudo automate-ctl create-enterprise ${enterprise} --ssh-pub-key-file=/root/${admin_user}.pem
fi
sudo automate-ctl create-user ${enterprise} ${admin_user} --password '${admin_password}' --roles admin
