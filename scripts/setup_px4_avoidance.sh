#!/bin/bash

echo " " && echo "This script installs PX4 Avoidance assumimg Ubuntu 18, ROS Melodic, Gazebo, MAVROS, ~/catkin_ws are installed" && echo " "

if [[ $(lsb_release -rs) != "18.04" ]]; then
    echo "This scripts works only for Ubuntu 18.04. Exiting..." && echo " "
fi

echo " " && echo "Installing avoidance module dependencies (pointcloud library and octomap)." && echo " "
sleep 1

if [ -z "$SUDO_PASS" ]; then
    sudo apt-get update && sudo apt-get install -y libpcl1 ros-melodic-octomap-* ros-melodic-stereo-image-proc ros-melodic-image-view ros-melodic-rqt-reconfigure
else
    echo $SUDO_PASS | sudo -S apt-get update && echo $SUDO_PASS |  sudo -S apt-get install -y libpcl1 ros-melodic-octomap-* ros-melodic-stereo-image-proc ros-melodic-image-view ros-melodic-rqt-reconfigure
fi


if [ ! -d "${HOME}/catkin_ws/src/avoidance" ]; then
    cd ${HOME}/catkin_ws/src
    git clone https://github.com/PX4/avoidance.git
else
    echo "avoidance already exists. Just pulling latest upstream...."
    cd ${HOME}/catkin_ws/src/avoidance
    git pull
fi

echo " " && echo "Build catkin_ws..." && echo " "
cd ${HOME}/catkin_ws
catkin build --cmake-args -DCMAKE_BUILD_TYPE=Release

echo "export GAZEBO_MODEL_PATH=\${GAZEBO_MODEL_PATH}:~/catkin_ws/src/avoidance/avoidance/sim/models:~/catkin_ws/src/avoidance/avoidance/sim/worlds" >> ~/.bashrc

source ${HOME}/.bashrc

echo " " && echo " ---------- PX4 acoidance setup is DONE! ----------" && echo " "