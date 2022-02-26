#!/bin/bash

# 
# Setup script for PX4 firmware, v1.12.3 and sitl development eco-system 
# Assumes Gazebo 11 is installed
# Author: Mohamed Abdelkader
# References: http://dev.px4.io/master/en/setup/dev_env_linux_ubuntu.html#sim_nuttx
#


# script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# check requirements.txt exists (script not run in source tree)
REQUIREMENTS_FILE="px4_requirements.txt"
if [[ ! -f "${DIR}/${REQUIREMENTS_FILE}" ]]; then
	echo "FAILED: ${REQUIREMENTS_FILE} needed in same directory as setup_px4_v1.12.3.sh (${DIR})."
	return 1
fi

echo "Installing PX4 general dependencies"

sudo apt-get update -y --quiet
sudo DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
	astyle \
	build-essential \
	ccache \
	clang \
	clang-tidy \
	cmake \
	cppcheck \
	doxygen \
	file \
	g++ \
	gcc \
	gdb \
	git \
	lcov \
	make \
	ninja-build \
	python3 \
	python3-dev \
	python3-pip \
	python3-setuptools \
	python3-wheel \
	rsync \
	shellcheck \
	unzip \
	xsltproc \
	zip \
	;

# Python3 dependencies
echo
echo "Installing PX4 Python3 dependencies"
pip3 install -r ${DIR}/px4_requirements.txt

# Simulation dependencies
sudo DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
		ant \
		openjdk-11-jre \
		openjdk-11-jdk \
		libvecmath-java \
		xmlstarlet \
		;

sudo DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
		gstreamer1.0-plugins-bad \
		gstreamer1.0-plugins-base \
		gstreamer1.0-plugins-good \
		gstreamer1.0-plugins-ugly \
		gstreamer1.0-gl \
		gstreamer1.0-libav \
		libeigen3-dev \
		libgazebo11-dev \
		libgstreamer-plugins-base1.0-dev \
		libimage-exiftool-perl \
		libopencv-dev \
		libxml2-utils \
		pkg-config \
		protobuf-compiler \
		dmidecode \
		bc \
		;

update-alternatives --set java $(update-alternatives --list java | grep "java-11")

#Setting up PX4 Firmware
if [ ! -d "${HOME}/PX4-Autopilot" ]; then
    cd ${HOME}
    git clone https://github.com/PX4/PX4-Autopilot.git --recursive
else
    echo "PX4-Autopilot directory already exists. Just pulling latest upstream...."
    cd ${HOME}/PX4-Autopilot
    git pull
fi
cd ${HOME}/PX4-Autopilot
make clean && make distclean
git checkout v1.12.3  && git submodule update --recursive

cd ${HOME}/PX4-Autopilot
DONT_RUN=1 make px4_sitl gazebo

#Copying this to  .bashrc file
grep -xF 'source ~/PX4-Autopilot/Tools/setup_gazebo.bash ~/PX4-Autopilot ~/PX4-Autopilot/build/px4_sitl_default' ${HOME}/.bashrc || echo "source ~/PX4-Autopilot/Tools/setup_gazebo.bash ~/PX4-Autopilot ~/PX4-Autopilot/build/px4_sitl_default" >> ${HOME}/.bashrc
grep -xF 'export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:~/PX4-Autopilot' ${HOME}/.bashrc || echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/PX4-Autopilot" >> ${HOME}/.bashrc
grep -xF 'export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:~/PX4-Autopilot/Tools/sitl_gazebo' ${HOME}/.bashrc || echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/PX4-Autopilot/Tools/sitl_gazebo" >> ${HOME}/.bashrc
grep -xF 'export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/gazebo-11/plugins' ${HOME}/.bashrc || echo "export GAZEBO_PLUGIN_PATH=\$GAZEBO_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/gazebo-11/plugins" >> ${HOME}/.bashrc

source ${HOME}/.bashrc

# Install QGroundControl
###### Not working yet!!!
sudo usermod -a -G dialout $USER
sudo apt-get remove modemmanager -y
sudo apt-get install fuse libpulse-mainloop-glib0 -y

cd ${HOME}
wget https://s3-us-west-2.amazonaws.com/qgroundcontrol/latest/QGroundControl.AppImage
chmod +x ./QGroundControl.AppImage

echo "**** Make sure to logout and login again ****"