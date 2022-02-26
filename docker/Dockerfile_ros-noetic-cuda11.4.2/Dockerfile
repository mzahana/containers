#
# ROS Noetic + CUDA 11.4.2
#

FROM mzahana/base-ubuntu20-cuda11.4.2:latest
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"

RUN wget --quiet http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - \
	&& sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -sc` main" > /etc/apt/sources.list.d/gazebo-stable.list' \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
        software-properties-common \
        apt-utils \
		ant \
		binutils \
		bc \
		dirmngr \
		gazebo11 \
		gstreamer1.0-plugins-bad \
		gstreamer1.0-plugins-base \
		gstreamer1.0-plugins-good \
		gstreamer1.0-plugins-ugly \
		libeigen3-dev \
		libgazebo11-dev \
		libgstreamer-plugins-base1.0-dev \
		libimage-exiftool-perl \
		libopencv-dev \
		libxml2-utils \
		mesa-utils \
		protobuf-compiler \
		x-window-system \
		ignition-edifice \
	&& apt-get -y autoremove \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# Some QT-Apps/Gazebo don't not show controls without this
ENV QT_X11_NO_MITSHM 1

# Use UTF8 encoding in java tools (needed to compile jMAVSim)
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8

# Install JSBSim
RUN wget https://github.com/JSBSim-Team/jsbsim/releases/download/v1.1.1a/JSBSim-devel_1.1.1-134.focal.amd64.deb
RUN dpkg -i JSBSim-devel_1.1.1-134.focal.amd64.deb

ENV ROS_DISTRO noetic

# setup ros keys
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list' \
	&& sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list' \
	&& sh -c 'echo "deb http://packages.ros.org/ros-shadow-fixed/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-shadow.list' \
	&& apt-get update \
	&& apt-get -y --quiet --no-install-recommends install \
		geographiclib-tools \
		libeigen3-dev \
		libgeographic-dev \
		libopencv-dev \
		libyaml-cpp-dev \
		python3-rosdep \
		python3-catkin-tools \
		python3-catkin-lint \
		ros-$ROS_DISTRO-gazebo-ros-pkgs \
		ros-$ROS_DISTRO-mavlink \
		ros-$ROS_DISTRO-mavros \
		ros-$ROS_DISTRO-mavros-extras \
		ros-$ROS_DISTRO-octomap \
		ros-$ROS_DISTRO-octomap-msgs \
		ros-$ROS_DISTRO-pcl-conversions \
		ros-$ROS_DISTRO-pcl-msgs \
		ros-$ROS_DISTRO-pcl-ros \
		ros-$ROS_DISTRO-ros-base \
		ros-$ROS_DISTRO-rostest \
		ros-$ROS_DISTRO-rosunit \
        ros-$ROS_DISTRO-tf-conversions \
        ros-$ROS_DISTRO-rqt-tf-tree \
		xvfb \
	&& geographiclib-get-geoids egm96-5 \
	&& apt-get -y autoremove \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

RUN pip3 install -U \
		osrf-pycommon

# bootstrap rosdep
RUN rosdep init && rosdep update

#
# PX4
#

# Insatll VS Code for easy code development
RUN apt-get update && wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
RUN apt-get update
RUN apt-get -y --quiet install code libgbm-dev

# Create catkin_ws at $HOME
RUN if [ ! -d "$HOME/catkin_ws" ]; then \
    mkdir -p $HOME/catkin_ws/src; fi

RUN cd $HOME/catkin_ws \
    && catkin init \
    && catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release \
    && catkin config --merge-devel \
    && catkin config --extend /opt/ros/$ROS_DISTRO \
    && catkin build

# # source catkin_ws inside .bashrc
RUN sed -i '/source ~\/catkin_ws\/devel\/setup.bash/d' /root/.bashrc && \
    sed -i 's+source /opt/ros/noetic/setup.bash+source /opt/ros/noetic/setup.bash\nsource ~/catkin_ws/devel/setup.bash+g' /root/.bashrc



RUN if [ ! -d "$HOME/src" ]; then \
    mkdir -p $HOME/src; fi

## TODO Need to create setup_px4_1.12.1.sh , before running the following RUN
# RUN if [ ! -d "$HOME/src/containers" ]; then \
#     cd $HOME/src \
#     && git clone https://github.com/mzahana/containers.git \
#     && cd $HOME/src/containers/scripts \
#     && echo "Cloning and building PX4 v1.12.1 ..." \
#     && ./setup_px4.sh; fi


# create and start as LOCAL_USER_ID
COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/bin/bash"]