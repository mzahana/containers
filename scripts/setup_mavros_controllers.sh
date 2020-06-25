#!/bin/bash

echo "arrow" | sudo -S apt update

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

#Adding mavros_controllers-1
if [ ! -d "$CATKIN_SRC/mavros_controllers-1" ]; then
    echo "Cloning the mavros_controllers-1 repo ..."
    cd $CATKIN_SRC
    git clone https://github.com/mzahana/mavros_controllers-1.git
    cd ../
else
    echo "mavros_controllers-1 already exists. Just pulling ..."
    cd $CATKIN_SRC/mavros_controllers-1
    git pull
    cd ../ 
fi

#Adding catkin_simple
if [ ! -d "$CATKIN_SRC/catkin_simple" ]; then
    echo "Cloning the catkin_simple repo ..."
    cd $CATKIN_SRC
    git clone https://github.com/catkin/catkin_simple
    cd ../
else
    echo "catkin_simple already exists. Just pulling ..."
    cd $CATKIN_SRC/catkin_simple
    git pull
    cd ../ 
fi

#Adding eigen_catkin
if [ ! -d "$CATKIN_SRC/eigen_catkin" ]; then
    echo "Cloning the eigen_catkin repo ..."
    cd $CATKIN_SRC
    git clone https://github.com/ethz-asl/eigen_catkin
    cd ../
else
    echo "eigen_catkin already exists. Just pulling ..."
    cd $CATKIN_SRC/eigen_catkin
    git pull
    cd ../ 
fi

#Adding eigen_catkin
if [ ! -d "$CATKIN_SRC/mav_comm" ]; then
    echo "Cloning the mav_comm repo ..."
    cd $CATKIN_SRC
    git clone https://github.com/ethz-asl/mav_comm
    cd ../
else
    echo "mav_comm already exists. Just pulling ..."
    cd $CATKIN_SRC/mav_comm
    git pull
    cd ../ 
fi

cd $CATKIN_WS
catkin build
source $CATKIN_WS/devel/setup.bash
