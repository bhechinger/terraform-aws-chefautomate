#!/bin/bash

echo 'Sleeping for a couple minutes to allow things to settle down first'
sleep 120
echo 'Done sleeping, let us get on with this'

sudo mkdir /root/.aws
sudo mv /tmp/terraform/aws_credentials /root/.aws/credentials
sudo chmod 600 /root/.aws/credentials
sudo mv /tmp/terraform/* /root/
sudo mv /tmp/terraform/.getssl /root/
sudo chmod 755 /root/dns_route53.py /root/s3_upload.py
sudo ln -s /root/dns_route53.py /root/dns_add_route53
sudo ln -s /root/dns_route53.py /root/dns_del_route53
sudo curl --silent -o /root/getssl https://raw.githubusercontent.com/srvrco/getssl/master/getssl
sudo chmod 755 /root/getssl

sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
if [ "${upgrade_chef}" == "true" ]; then
    sudo yum update -y
fi
sudo yum install -y python-pip
sudo pip install boto3 dnspython

echo 'api_fqdn "${fqdn}"' | sudo tee -a /etc/chef-marketplace/marketplace.rb

if [ "${enable_telemetry}" == "true" ]; then
    sudo automate-ctl telemetry enable
fi

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
    sudo automate-ctl delete-enterprise default
    sudo automate-ctl create-enterprise ${enterprise} --ssh-pub-key-file=/root/${admin_user}.pem
fi

sudo automate-ctl create-user ${enterprise} ${admin_user} --password '${admin_password}' --roles admin

sudo /root/s3_upload.py "${bucket_name}" "/root/${admin_user}-validator.pem" "/root/${admin_user}.pem" "${region}"

echo "Done setting up Chef Automate server" > /tmp/setup_done
