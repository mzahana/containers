 #! /bin/bash
# Runs a docker container for PSU delivery drone project simulation environment
# Requires:
#   - docker
#   - nvidia-docker
#   - an X server
# Optional:
#   - device mounting such as: joystick mounted to /dev/input/js0
#
# Authors: Mohammed Abdelkader
 
DOCKER_REPO="mzahana/px4-ros-melodic-cuda10.1:latest"
CONTAINER_NAME="px4_octune"
SHARED_VOLUME_NAME="shared_volume"
WORKSPACE_DIR=~/${CONTAINER_NAME}_${SHARED_VOLUME_NAME}
CMD=""
DOCKER_OPTS=

# User name inside container
USER_NAME=arrow
SUDO_PASS=arrow

# For coloring terminal output
RED='\033[0;31m'
NC='\033[0m' # No Color
if [ -z "${PERSONAL_GIT_TOKEN}" ]; then
    echo -e "${RED} Please export GIT_TOKEN before using this script ${NC}" && echo
    exit 10
fi

# Get the current version of docker-ce
# Strip leading stuff before the version number so it can be compared
DOCKER_VER=$(dpkg-query -f='${Version}' --show docker-ce | sed 's/[0-9]://')
if dpkg --compare-versions 19.03 gt "$DOCKER_VER"
then
    echo "Docker version is less than 19.03, using nvidia-docker2 runtime"
    if ! dpkg --list | grep nvidia-docker2
    then
        echo "Please either update docker-ce to a version greater than 19.03 or install nvidia-docker2"
	exit 1
    fi
    DOCKER_OPTS="$DOCKER_OPTS --runtime=nvidia"
else
    DOCKER_OPTS="$DOCKER_OPTS --gpus all"
fi
echo "GPU arguments: $DOCKER_OPTS"

# This will enable running containers with different names
# It will create a local workspace and link it to the image's catkin_ws
if [ "$1" != "" ]; then
    CONTAINER_NAME=$1
fi
WORKSPACE_DIR=~/${CONTAINER_NAME}_shared_volume
if [ ! -d $WORKSPACE_DIR ]; then
    mkdir -p $WORKSPACE_DIR
fi
echo "Container name:$CONTAINER_NAME WORSPACE DIR:$WORKSPACE_DIR" 

XAUTH=/tmp/.docker.xauth
xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
if [ ! -f $XAUTH ]
then
    echo XAUTH file does not exist. Creating one...
    touch $XAUTH
    chmod a+r $XAUTH
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    fi
fi

# Prevent executing "docker run" when xauth failed.
if [ ! -f $XAUTH ]
then
  echo "[$XAUTH] was not properly created. Exiting..."
  exit 1
fi


echo "Shared WORKSPACE_DIR: $WORKSPACE_DIR";
echo "Docker container username:" $USER_NAME

#not-recommended - T.T please fix me, check this: http://wiki.ros.org/docker/Tutorials/GUI
xhost +local:root

CMD="/bin/bash"
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER_NAME})" ]; then
        # cleanup
        echo "Restarting the container..."
        docker start ${CONTAINER_NAME}
    fi

    docker exec -it --user $USER_NAME ${CONTAINER_NAME} bash

else

echo "Starting Container: ${CONTAINER_NAME} with REPO: $DOCKER_REPO"


 
if [ -z ${PERSONAL_GIT_TOKEN} ];then
    CLONE_PX4_OCTUNE="git clone https://github.com/mzahana/px4_octune_ros.git"
else
    CLONE_PX4_OCTUNE="git clone https://$PERSONAL_GIT_TOKEN@github.com/mzahana/px4_octune_ros.git"
fi
 CMD="export GIT_TOKEN=${PERSONAL_GIT_TOKEN} && export SUDO_PASS=arrow && \
      export OCTUNE_DIR=\$HOME/$SHARED_VOLUME_NAME && \
      if [ ! -d "\$HOME/$SHARED_VOLUME_NAME/catkin_ws/" ]; then
      mkdir -p \$HOME/$SHARED_VOLUME_NAME/catkin_ws/src
      cd \$HOME/$SHARED_VOLUME_NAME/catkin_ws
      catkin init && catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release && catkin config --merge-devel && catkin config --extend /opt/ros/\$ROS_DISTRO && catkin build
      fi && \
      cd \$HOME/$SHARED_VOLUME_NAME/catkin_ws/src && \
      echo '-----------------------------' && echo && \
      if [ ! -d "\$HOME/$SHARED_VOLUME_NAME/catkin_ws/src/px4_octune_ros" ]; then
      $CLONE_PX4_OCTUNE
      cd \$HOME/$SHARED_VOLUME_NAME/catkin_ws/src/px4_octune_ros && ./scripts/setup.sh
      cd \$HOME/$SHARED_VOLUME_NAME/catkin_ws && catkin build
      fi && \
      source \$HOME/.bashrc && /bin/bash"

echo "Running container ${CONTAINER_NAME}..."
#-v /dev/video0:/dev/video0 \
#    -p 14570:14570/udp \
docker run -it \
    --network host \
    --user=$USER_NAME \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="/etc/localtime:/etc/localtime:ro" \
    --volume="$WORKSPACE_DIR:/home/$USER_NAME/shared_volume:rw" \
    --volume="/dev/input:/dev/input" \
    --volume="$XAUTH:$XAUTH" \
    -env="XAUTHORITY=$XAUTH" \
    --workdir="/home/$USER_NAME" \
    --name=${CONTAINER_NAME} \
    --privileged \
    $DOCKER_OPTS \
    ${DOCKER_REPO} \
    bash -c "${CMD}"
fi
   
#xhost -local:root
