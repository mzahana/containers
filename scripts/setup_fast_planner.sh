#!/bin/bash

echo "arrow" | sudo -S apt update
# Required for Fast-Planner
echo "arrow" | sudo -S apt install ros-melodic-nlopt libarmadillo-dev -y

CATKIN_WS=${HOME}/catkin_ws
CATKIN_SRC=${HOME}/catkin_ws/src

if [ ! -d "$CATKIN_WS"]; then
	echo "Creating $CATKIN_WS ... "
	mkdir -p $CATKIN_SRC
fi

if [ ! -d "$CATKIN_SRC"]; then
	echo "Creating $CATKIN_SRC ..."
fi

# Configure catkin_Ws
cd $CATKIN_WS
catkin init
catkin config --merge-devel
catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release
catkin build

#Adding catkin simple
if [ ! -d "$CATKIN_SRC/Fast-Planner" ]; then
    echo "Cloning the Fast-Planner repo ..."
    cd $CATKIN_SRC
    git clone https://github.com/mzahana/Fast-Planner.git
    cd ../
else
    echo "Fast-Planner already exists. Just pulling ..."
    cd $CATKIN_SRC/Fast-Planner
    git pull
    cd ../ 
fi

# Checkout ROS Mellodic branch 
cd $CATKIN_SRC/Fast-Planner
git checkout changes_for_ros_melodic

cd $CATKIN_WS
catkin build multi_map_server
catkin build

grep -xF 'source $HOME/catkin_ws/devel/setup.bash' ${HOME}/.bashrc || echo "source $HOME/catkin_ws/devel/setup.bash" >> $HOME/.bashrc
