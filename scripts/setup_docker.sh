#!/bin/bash
echo "Installing Docker ..."
read -p "Enter user password please: " -s pass
# Source: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04
echo $pass | sudo -S apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo $pass | sudo -S add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
echo $pass | sudo -S apt-get update -y
echo $pass | sudo -S apt-get install docker-ce -y

echo "Allowing docker to run as non-root user ..."
echo $pass | sudo -S usermod -aG docker ${USER}
echo $pass | su -l ${USER}


echo "Setting up Nvidia docker ..."
# Source: https://github.com/NVIDIA/nvidia-docker
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

echo $pass | sudo -S apt-get update -y
echo $pass | sudo -S apt-get install -y nvidia-container-toolkit
echo $pass | sudo -S systemctl restart docker

echo "Installing nvidia-container-runtime ..."
echo $pass | sudo -S apt-get install nvidia-container-runtime -y
