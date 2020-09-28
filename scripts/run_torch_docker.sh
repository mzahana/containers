 #! /bin/bash
# Runs a docker container for Pytorch development
# Requires:
#   - docker
#   - nvidia-docker
#   - an X server
# Optional:
#   - device mounting such as: joystick mounted to /dev/input/js0
#
# Authors: Mohammed Abdelkader
 
DOCKER_REPO="mzahana/ubuntu18-cuda10.1-cudnn7-torch1.4:latest"
CONTAINER_NAME="pytorch1.4"
WORKSPACE_DIR=~/pytorch_ws
CMD=""
DOCKER_OPTS=

# User name inside container
USER_NAME=torch

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
    WORKSPACE_DIR=~/$1_ws
    if [ ! -d $WORKSPACE_DIR ]; then
        mkdir -p $WORKSPACE_DIR
    fi
    echo "Container name:$1 WORSPACE DIR:$WORKSPACE_DIR" 
fi

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
xhost +local:root
 
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
    --user=$USER_NAME \
    --ipc=host \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="/etc/localtime:/etc/localtime:ro" \
    --volume="$WORKSPACE_DIR:/home/$USER_NAME/pytorch_ws:rw" \
    --volume="/dev/input:/dev/input" \
    --volume="$XAUTH:$XAUTH" \
    -env="XAUTHORITY=$XAUTH" \
    --workdir="/home/$USER_NAME" \
    --name=${CONTAINER_NAME} \
    --privileged \
    $DOCKER_OPTS \
    ${DOCKER_REPO} \
    bash
fi
   
xhost -local:root
