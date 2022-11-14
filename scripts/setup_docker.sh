#!/bin/bash

# To change the printing colors
RED='\033[0;31m'
NC='\033[0m' # No Color


echo "Installing Docker ..."
read -p "Enter user password please, for sudo: " -s pass
# Source: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04
echo $pass | sudo -S apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo $pass | sudo -S add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
echo $pass | sudo -S apt-get update -y
echo $pass | sudo -S apt-get install docker-ce -y

echo -e "${RED}Adding new group 'docker' ...${NC}"
echo $pass | sudo -S groupadd docker

echo -e "${RED}Allowing docker to run as non-root user ...${NC}"
echo -e "${RED}Adding $USER in docker group...${NC}"
echo $pass | sudo -S usermod -aG docker ${USER}

#### NOTE: The following 2 commands will start in a new shell 
#        and the rest of the script will not execute untill you exit that shell
#        So, we advise to re-login again manually
# newgrp docker
# echo $pass | su -l ${USER}

echo $pass | sudo -S systemctl enable docker

# Source: https://github.com/NVIDIA/nvidia-docker
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

echo $pass | sudo -S apt-get update -y
echo -e "${RED}Installing nvidia-docker2 ...${NC}"
echo $pass | sudo -S apt-get install -y nvidia-docker2
echo $pass | sudo -S apt-get install -y nvidia-container-toolkit

echo "Installing nvidia-container-runtime ..."
echo $pass | sudo -S apt-get install nvidia-container-runtime -y

echo -e "${RED}Restarting Docker daeomn...${NC}"
echo $pass | sudo -S systemctl restart docker



echo -e "${RED} ****************** Make sure to logout and login again for docker to take effect ****************** ${NC}"
