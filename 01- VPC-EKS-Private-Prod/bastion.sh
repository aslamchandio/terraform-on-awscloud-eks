#!/bin/bash
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y
sudo hostnamectl set-hostname Bastion-Host
sudo ufw allow proto tcp from any to any port 22,80,443
sudo apt install zip unzip wget net-tools vim nano htop -y
sudo echo 'y' | sudo ufw enable