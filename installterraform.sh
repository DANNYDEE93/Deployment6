#!bin/bash

#download files and keyrings necessary for terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
#decrypt and add keys to directory
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb\_release -cs) main" | sudo tee /etc/apt/so>
#update system and install terraform
sudo apt update && sudo apt install terraform

sudo apt update
