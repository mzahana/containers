# This dockerfile installs px4_pid_tuner inside Ubuntu 18 image
#   https://github.com/mzahana/px4_pid_tuner
#
ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE}
LABEL maintainer="mohamedashraf123@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV CONTAINER_USER=px4

WORKDIR /workspace

# add the ROS deb repo to the apt sources list
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    sudo \
		cmake \
		build-essential \
		curl \
		wget \
		gnupg2 \
		lsb-release \
		gedit \
		net-tools \
		iputils-ping \
		nano \
		bash-completion \
		python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

    # Install CMake
    # RUN sudo apt-get purge cmake && \
    # wget https://github.com/Kitware/CMake/releases/download/v3.15.2/cmake-3.15.2.tar.gz && \
    # tar -zxvf cmake-3.15.2.tar.gz && \
    #  cd cmake-3.15.2 && \
    #  ./bootstrap && \
    #  make && make install

# Add riot user
RUN useradd --shell /bin/bash -u 1000 -c "" -m $CONTAINER_USER && usermod -a -G dialout $CONTAINER_USER && echo "$CONTAINER_USER:$CONTAINER_USER" | chpasswd && adduser $CONTAINER_USER sudo

# Add user to dialout group
RUN usermod -aG dialout $CONTAINER_USER
RUN usermod -aG tty $CONTAINER_USER

# Switch user
USER $CONTAINER_USER

# Create src folder inside the HOME folder
# This is to host non-ROS packages to install from source
RUN cd /home/$CONTAINER_USER && mkdir src

RUN echo "source /etc/profile.d/bash_completion.sh" >> /home/$CONTAINER_USER/.bashrc

RUN cd ${HOME}/src && \
    git clone https://github.com/mzahana/px4_pid_tuner.git && \
    cd px4_pid_tuner && git checkout ubuntu18


CMD ["bash"]
WORKDIR /home/$CONTAINER_USER
