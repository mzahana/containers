#
# ROS + Gazebo + PX4 development environment
#

FROM mzahana/ros-melodic-cuda10.1:latest
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"
USER arrow
ENV DEBIAN_FRONTEND noninteractive
ENV ARROW_HOME /home/arrow



RUN if [ ! -d "$ARROW_HOME/src" ]; then \
    mkdir -p $ARROW_HOME/src; fi

RUN if [ ! -d "$ARROW_HOME/src/containers" ]; then \
    cd $ARROW_HOME/src \
    && git clone https://github.com/mzahana/containers.git \
    && cd $ARROW_HOME/src/containers/scripts \
    && echo "Cloning and building PX4 v1.10.1 ..." \
    && ./setup_px4.sh; fi

#RUN echo arrow | sudo -S chown -R arrow:arrow /home/arrow
    

