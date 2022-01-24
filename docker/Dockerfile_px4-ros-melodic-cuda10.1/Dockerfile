#
# ROS Melodic + Gazebo 9 + PX4 development environment
#

FROM mzahana/ros-melodic-cuda10.1:latest
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"
USER arrow
ENV DEBIAN_FRONTEND noninteractive
ENV ARROW_HOME /home/arrow



RUN echo "arrow" | sudo -S apt-get update && sudo apt-get -y --quiet --no-install-recommends install software-properties-common apt-utils

# Insatll VS Code for easy code development
RUN echo "arrow" | sudo -S apt-get update && wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
RUN echo "arrow" | sudo -S add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
RUN echo "arrow" | sudo -S apt-get update
RUN echo "arrow" | sudo -S apt-get -y --quiet install code libgbm-dev

# source catkin_ws inside .bashrc
RUN sed -i '/source ~\/catkin_ws\/devel\/setup.bash/d' $HOME/.bashrc && \
    sed -i 's+source /opt/ros/melodic/setup.bash+source /opt/ros/melodic/setup.bash\nsource ~/catkin_ws/devel/setup.bash+g' $ARROW_HOME/.bashrc


# Install some useful ros tf packages
RUN echo "arrow" | sudo -S  apt-get install ros-melodic-tf-conversions ros-melodic-rqt-tf-tree -y

RUN if [ ! -d "$ARROW_HOME/src" ]; then \
    mkdir -p $ARROW_HOME/src; fi

RUN if [ ! -d "$ARROW_HOME/src/containers" ]; then \
    cd $ARROW_HOME/src \
    && git clone https://github.com/mzahana/containers.git \
    && cd $ARROW_HOME/src/containers/scripts \
    && echo "Cloning and building PX4 v1.10.1 ..." \
    && ./setup_px4.sh; fi

RUN echo "export PATH=\$PATH:/home/arrow/.local/bin:/home/arrow/.local/bin" >> /home/arrow/.bashrc
RUN echo "export PATH=\$PATH:/usr/local/cuda-10.1/bin" >> /home/arrow/.bashrc
RUN echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/cuda-10.1/lib64:/usr/local/cuda-10.1/targets/x86_64-linux/lib/:/usr/local/cuda/extras/CUPTI/lib64/" >> /home/arrow/.bashrc
RUN echo "export CUDA_HOME=/usr/local/cuda" >> /home/arrow/.bashrc
