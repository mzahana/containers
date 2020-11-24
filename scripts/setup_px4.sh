#!/bin/bash

# 
# Setup script for PX4 firmware and sitl development eco-system 
# Author: Tarek Taha, Mohamed Abdelkader
# References: http://dev.px4.io/master/en/setup/dev_env_linux_ubuntu.html#sim_nuttx
#

if [ -z "$1" ]; then
    ARROW_HOME=$HOME
else
    ARROW_HOME=$1
fi	

if [ -f /.dockerenv ]; then
	pass=arrow
	echo "Running within docker, installing initial dependencies";
	echo $pass | sudo -S apt-get --quiet -y update && DEBIAN_FRONTEND=noninteractive apt-get --quiet -y install \
		ca-certificates \
		gnupg \
		lsb-core \
		sudo \
		wget \
		;
else
	read -p "Enter user password please (for sudo): " -s pass
fi

# script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# check requirements.txt exists (script not run in source tree)
REQUIREMENTS_FILE="px4_requirements.txt"
if [[ ! -f "${DIR}/${REQUIREMENTS_FILE}" ]]; then
	echo "FAILED: ${REQUIREMENTS_FILE} needed in same directory as setup_px4.sh (${DIR})."
	return 1
fi

echo "Installing PX4 general dependencies"

echo $pass | sudo -S apt-get update -y --quiet
echo $pass | sudo -S DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
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
pip3 install --user -r ${DIR}/px4_requirements.txt

# Simulation dependencies
echo $pass | sudo -S DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
		ant \
		openjdk-11-jre \
		openjdk-11-jdk \
		libvecmath-java \
		xmlstarlet \
		;

echo $pass | sudo -S DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
		gstreamer1.0-plugins-bad \
		gstreamer1.0-plugins-base \
		gstreamer1.0-plugins-good \
		gstreamer1.0-plugins-ugly \
		gstreamer1.0-libav \
		libeigen3-dev \
		libgazebo9-dev \
		libgstreamer-plugins-base1.0-dev \
		libimage-exiftool-perl \
		libopencv-dev \
		libxml2-utils \
		pkg-config \
		protobuf-compiler \
		dmidecode \
		bc \
		;

echo $pass | sudo -S update-alternatives --set java $(update-alternatives --list java | grep "java-11")

#Setting up PX4 Firmware
if [ ! -d "${HOME}/Firmware" ]; then
    cd ${HOME}
    git clone https://github.com/PX4/Firmware.git --recursive
else
    echo "Firmware already exists. Just pulling latest upstream...."
    cd ${HOME}/Firmware
    git pull
fi
cd ${HOME}/Firmware
make clean && make distclean
git checkout v1.10.1  && git submodule update --recursive

cd ${HOME}/Firmware/Tools/sitl_gazebo/external/OpticalFlow
git submodule update --recursive
cd ${HOME}/Firmware/Tools/sitl_gazebo/external/OpticalFlow/external/klt_feature_tracker
git submodule update --recursive
#### NOTE: in PX4 v1.10.1, there is a bug in Firmware/Tools/sitl_gazebo/include/gazebo_opticalflow_plugin.h:43:18
#### NOTE  #define HAS_GYRO TRUE needs to be replaced by #define HAS_GYRO true
sed -i 's/#define HAS_GYRO.*/#define HAS_GYRO true/' ${HOME}/Firmware/Tools/sitl_gazebo/include/gazebo_opticalflow_plugin.h

cd ${HOME}/Firmware
DONT_RUN=1 make px4_sitl gazebo

#Copying this to  .bashrc file
grep -xF 'source ~/Firmware/Tools/setup_gazebo.bash ~/Firmware ~/Firmware/build/px4_sitl_default' ${HOME}/.bashrc || echo "source ~/Firmware/Tools/setup_gazebo.bash ~/Firmware ~/Firmware/build/px4_sitl_default" >> ${HOME}/.bashrc
grep -xF 'export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:~/Firmware' ${HOME}/.bashrc || echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/Firmware" >> ${HOME}/.bashrc
grep -xF 'export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:~/Firmware/Tools/sitl_gazebo' ${HOME}/.bashrc || echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/Firmware/Tools/sitl_gazebo" >> ${HOME}/.bashrc
#grep -xF 'export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:/home/aaal/catkin_ws/src/swarm_sim/models' ${HOME}/.bashrc || echo "export GAZEBO_MODEL_PATH=\$GAZEBO_MODEL_PATH:/home/aaal/catkin_ws/src/swarm_sim/models" >> ${HOME}/.bashrc
grep -xF 'export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/gazebo-9/plugins' ${HOME}/.bashrc || echo "export GAZEBO_PLUGIN_PATH=\$GAZEBO_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/gazebo-9/plugins" >> ${HOME}/.bashrc

source ${HOME}/.bashrc

# Install QGroundControl
echo $pass | sudo -S usermod -a -G dialout $USER
echo $pass | sudo -S apt-get remove modemmanager -y
echo $pass | sudo -S apt-get install gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl -y

wget https://s3-us-west-2.amazonaws.com/qgroundcontrol/latest/QGroundControl.AppImage
chmod +x ./QGroundControl.AppImage

echo "**** Make sure to logout and login again ****"

