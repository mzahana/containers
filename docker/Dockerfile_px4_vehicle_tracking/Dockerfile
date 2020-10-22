FROM mzahana/px4-ros-melodic-cuda10.1:latest
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV ARROW_HOME /home/arrow

USER arrow

RUN echo "arrow" | sudo -S apt-get update && sudo apt-get -y --quiet --no-install-recommends install software-properties-common apt-utils

# For VS Code
RUN echo "arrow" | sudo -S apt-get update && wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
RUN echo "arrow" | sudo -S add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
RUN echo "arrow" | sudo -S apt-get update
RUN echo "arrow" | sudo -S apt-get -y --quiet install code libgbm-dev

# catkin_ws
RUN mkdir -p $ARROW_HOME/catkin_ws/src && echo "arrow" | sudo -S chown -R arrow $ARROW_HOME/catkin_ws \
    && cd ~/catkin_ws \
    && catkin init \
    && catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release \
    && catkin config --merge-devel \
    && catkin config --extend /opt/ros/$ROS_DISTRO \
    && catkin build

# source catkin_ws in .bashrc
RUN sed -i '/source ~\/catkin_ws\/devel\/setup.bash/d' $HOME/.bashrc && \
    sed -i 's+source /opt/ros/melodic/setup.bash+source /opt/ros/melodic/setup.bash\nsource ~/catkin_ws/devel/setup.bash+g' $ARROW_HOME/.bashrc

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
