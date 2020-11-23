FROM mzahana/px4-ros-melodic-cuda10.1:latest
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV ARROW_HOME /home/arrow

USER arrow

# Installing Husky simulation packages
RUN echo "arrow" | sudo -S apt-get install ros-$ROS_DISTRO-husky-desktop ros-$ROS_DISTRO-husky-simulator -y

# Install apriltag_ros
RUN echo "arrow" | sudo -S apt-get install ros-$ROS_DISTRO-apriltag-ros -y
RUN echo "arrow" | sudo -S  apt-get install ros-melodic-tf-conversions ros-melodic-rqt-tf-tree -y

RUN cd $ARROW_HOME/catkin_ws/src && \
    git clone https://github.com/mzahana/mavros_apriltag_tracking.git

RUN cp -R $ARROW_HOME/catkin_ws/src/mavros_apriltag_tracking/models/typhoon_h480 $ARROW_HOME/Firmware/Tools/sitl_gazebo/models/ 

RUN echo "arrow" | sudo -S cp $ARROW_HOME/catkin_ws/src/mavros_apriltag_tracking/models/custom_husky/husky.urdf.xacro /opt/ros/melodic/share/husky_description/urdf/

RUN cd $ARROW_HOME/catkin_ws && catkin build
