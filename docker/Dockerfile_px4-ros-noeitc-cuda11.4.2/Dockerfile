#
# ROS Noetic + Gazebo 11 + PX4 v1.13.1 development environment
#

FROM mzahana/ros-noetic-cuda11.4.2:latest
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"
ENV DEBIAN_FRONTEND noninteractive

#
# source catkin_ws inside .bashrc
#
RUN sed -i '/source ~\/catkin_ws\/devel\/setup.bash/d' $HOME/.bashrc && \
    sed -i 's+source /opt/ros/noetic/setup.bash+source /opt/ros/noetic/setup.bash\nsource ~/catkin_ws/devel/setup.bash+g' $HOME/.bashrc

#
# Setting up PX4 Firmware, v1.13.1
#
RUN if [ ! -d "${HOME}/PX4-Autopilot" ]; then \
        cd ${HOME} && git clone https://github.com/PX4/PX4-Autopilot.git --recursive; \
    else \
        echo "PX4-Autopilot directory already exists. Just pulling latest upstream...." \
        && cd ${HOME}/PX4-Autopilot \
        && git pull; fi
#
# Build PX4
#
RUN echo
RUN cd ${HOME}/PX4-Autopilot \
    && git checkout v1.13.1  \
    && make clean && make distclean && DONT_RUN=1 make px4_sitl gazebo
    # && git submodule update --recursive

# RUN DONT_RUN=1 make px4_sitl gazebo

# Install xmlstarlet for Gazebo sdf models
RUN apt install -y xmlstarlet

#
# Export neccessary env variables
#
RUN echo "source ~/PX4-Autopilot/Tools/setup_gazebo.bash ~/PX4-Autopilot ~/PX4-Autopilot/build/px4_sitl_default" >> ${HOME}/.bashrc
RUN echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/PX4-Autopilot" >> ${HOME}/.bashrc
RUN echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/PX4-Autopilot/Tools/sitl_gazebo" >> ${HOME}/.bashrc
RUN echo "export GAZEBO_PLUGIN_PATH=\$GAZEBO_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/gazebo-11/plugins" >> ${HOME}/.bashrc