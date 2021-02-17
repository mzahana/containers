 #! /bin/bash
#   - an X server
# Optional:
#   - device mounting such as: joystick mounted to /dev/input/js0
#
# Authors: Mohammed Abdelkader
 
#sDOCKER_REPO="mzahana/multi_drone_surveillance_sim:latest"
DOCKER_REPO="mzahana/px4-pid-tuner:latest"
CONTAINER_NAME="pid_tuner"
WORKSPACE_DIR=~/${CONTAINER_NAME}_shared_volume
CMD=""

# User name inside container
USER_NAME=px4

# This will enable running containers with different names
# It will create a local workspace and link it to the image's catkin_ws
if [ "$1" != "" ]; then
    CONTAINER_NAME=$1
fi
WORKSPACE_DIR=~/${CONTAINER_NAME}_shared_volume
if [ ! -d $WORKSPACE_DIR ]; then
    mkdir -p $WORKSPACE_DIR
fi
echo "Container name:${CONTAINER_NAME} WORSPACE DIR:$WORKSPACE_DIR" 

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


xhost +local:root
 
echo "Starting Container: ${CONTAINER_NAME} with REPO: $DOCKER_REPO"

if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER_NAME})" ]; then
        # cleanup
        echo "Restarting the container..."
        docker start ${CONTAINER_NAME}
    fi

    docker exec -it --user $USER_NAME ${CONTAINER_NAME} bash

else


# The following command install dependecies of px4_pid_tuner. It gets executed the first time the container is run
 CMD="cd \${HOME}/src/px4_pid_tuner && git pull && /bin/bash"

echo "Running container ${CONTAINER_NAME}..."
#-v /dev/video0:/dev/video0 \
#    -p 14570:14570/udp \
docker run -it \
    --user=$USER_NAME \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="/etc/localtime:/etc/localtime:ro" \
    --volume="$WORKSPACE_DIR:/home/$USER_NAME/shared_volume:rw" \
    --volume="$XAUTH:$XAUTH" \
    -env="XAUTHORITY=$XAUTH" \
    --workdir="/home/$USER_NAME" \
    --name=${CONTAINER_NAME} \
    --privileged \
    ${DOCKER_REPO} \
    bash -c "${CMD}"
fi
   
#xhost -local:root
