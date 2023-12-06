#!/bin/bash

# This should run in the terraform workspace that you want to manage the keys from.
# ssh agent should be running

ssh-add ~/.ssh/id_rsa_terraform_testapp.pem

BASTION_IP="$(terraform output -raw bastion_public_ip)"
KEY_PATH="$(terraform output -raw ssh_key_path)"
BACKEND_IPS="$(terraform output -raw backend_ips)"

echo "#####################"
echo "# SSH Config        #"
echo "#####################"
echo "Copy the following content into ~/.ssh/config"
echo "#### copy from here"
sed -e "s/BASTIONIP/$BASTION_IP/" \
    -e "s/BACKENDIPS/$BACKEND_IPS/" ../../scripts/ssh_config_template
echo "### end of content to copy"

echo ""
echo "Updating ansible inventory..."
# COUNTER=0
echo "127.0.0.1" > ../../ansible/hosts.cfg
echo "" > ../../ansible/hosts.cfg
echo "[backend]" >> ../../ansible/hosts.cfg

for h in $BACKEND_IPS; do
  echo "${h} ansible_user=ubuntu" >> ../../ansible/hosts.cfg
done