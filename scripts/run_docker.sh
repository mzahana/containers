 #! /bin/bash
# Runs a docker container for Autonomous Aerial Lab development
# Requires:
#   - docker
#   - nvidia-docker
#   - an X server
# Optional:
#   - device mounting such as: joystick mounted to /dev/input/js0
#
# Authors: Tarek Taha, Mohammed Abdelkader
 
DOCKER_REPO="mzahana/px4-ros-melodic-cuda10.1:latest"
#DOCKER_REPO="mzahana/ros-melodic-sim-cudagl-dev-env-10.1:latest"
CONTAINER_NAME="px4"
WORKSPACE_DIR=~/${CONTAINER_NAME}_shared_volume
CMD=""
DOCKER_OPTS=

# User name inside container
USER_NAME=arrow

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


echo "WORKSPACE_DIR: $WORKSPACE_DIR";
echo "Username:" $USER_NAME
#not-recommended - T.T please fix me, check this: http://wiki.ros.org/docker/Tutorials/GUI
#xhost +si:localuser:root
xhost +
 
echo "Starting Container: ${CONTAINER_NAME} with REPO: $DOCKER_REPO"
 
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER_NAME})" ]; then
        # cleanup
        docker start ${CONTAINER_NAME}
    fi
    if [ -z "$CMD" ]; then
        docker exec -it --user $USER_NAME ${CONTAINER_NAME} bash
    else
        docker exec -it --user $USER_NAME ${CONTAINER_NAME} bash -c "$CMD"
    fi
else
echo "Running container ${CONTAINER_NAME}..."
#-v /dev/video0:/dev/video0 \
#    -p 14570:14570/udp \

docker run -it \
    --network host \
    --user=$USER_NAME \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    -v /dev:/dev \
    --group-add=dialout \
    --group-add=video \
    --group-add=tty \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix" \
    --volume="/etc/localtime:/etc/localtime:ro" \
    --volume="$WORKSPACE_DIR:/home/$USER_NAME/shared_volume:rw" \
    --volume="$XAUTH:$XAUTH" \
    -env="XAUTHORITY=$XAUTH" \
    --workdir="/home/$USER_NAME" \
    --name=${CONTAINER_NAME} \
    --privileged \
    $DOCKER_OPTS \
    ${DOCKER_REPO} \
    bash #-c "cd ~/catkin_ws && catkin build minkindr_conversions && catkin build && cd && source .bashrc && /bin/bash"
fi
   
#xhost -local:root
