#
# Ubuntu 18 + CUDA 10.1 + CUDNN7 + Torch 1.4 Development Environment
#

FROM nvidia/cuda:10.1-cudnn7-runtime-ubuntu18.04
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update && apt-get -y --quiet --no-install-recommends install software-properties-common apt-utils

# For Python3.7
RUN add-apt-repository ppa:deadsnakes/ppa

RUN apt-get -y --quiet --no-install-recommends install \
		sudo \
		nano \
		gedit \
		net-tools \
		iputils-* \
		bash-completion \
		autotools-dev \
		dh-autoreconf \
		bzip2 \
		ca-certificates \
		ccache \
		cmake \
		cppcheck \
		curl \
		dirmngr \
		doxygen \
		file \
		g++ \
		gcc \
		gdb \
		git \
		gnupg \
		gosu \
		lcov \
		libfreetype6-dev \
		libgtest-dev \
		libpng-dev \
		lsb-release \
		make \
		ninja-build \
		openjdk-8-jdk \
		openjdk-8-jre \
		openssh-client \
		pkg-config \
		python-pip \
		python-pygments \
		python-setuptools \
		python-wstool \
		locate \
		rsync \
		shellcheck \
		tzdata \
		unzip \
		wget \
		xsltproc \
		zip \
                apt-transport-https \
                python3.7 \
                python3-pip \
	&& apt-get -y autoremove \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# For VS Code
RUN wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
RUN apt-get update
RUN apt-get -y --quiet install code libgbm-dev

# gtest
RUN cd /usr/src/gtest \
	&& mkdir build && cd build \
	&& cmake .. && make \
	&& cp *.a /usr/lib \
	&& cd .. && rm -rf build

RUN python -m pip install --upgrade pip \
	&& pip install setuptools pkgconfig wheel \
	&& pip install argparse argcomplete coverage jinja2 empy numpy requests serial toml pyyaml cerberus

# Setting default Python3 to be version 3.7
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2
RUN update-alternatives --set python3 /usr/bin/python3.7

# Requirements for Dynonet package
RUN pip3 install numpy scipy pandas matplotlib setuptools
RUN pip3 install control
RUN pip3 install torch==1.4.0 torchvision==0.5.0 --no-cache-dir

# Installing OpenCV 3.4.1 (Prerequisites)
RUN apt-get update && apt-get upgrade

RUN apt-get -y --quiet --no-install-recommends install \
		gcc-5 \
		g++-5 \
		build-essential \
		libjpeg8-dev \
		libtiff5-dev \
		libjasper-dev \
		libpng12-dev \
		libavcodec-dev \
		libavformat-dev \
		libswscale-dev \
		libv4l-dev \
		libxvidcore-dev \
		libx264-dev \
		libgtk-3-dev \
		libatlas-base-dev \
		gfortran \
		python-dev 
RUN pip uninstall opencv-python
RUN apt -y --quiet remove \
		libopencv* \
		python-opencv \
		ros-melodic-opencv3 \
		ros-melodic-cv-bridge

RUN cd ~ 
RUN wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.4.1.zip
RUN unzip opencv.zip
RUN wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/3.4.1.zip
RUN unzip opencv_contrib.zip

RUN sed -i '455i#if defined __cplusplus' ~/opencv-3.4.1/modules/core/include/opencv2/core/cvdef.h
RUN sed -i '498i#endif' ~/opencv-3.4.1/modules/core/include/opencv2/core/cvdef.h
RUN sed -i '137i#if defined __cplusplus' ~/opencv-3.4.1/modules/highgui/include/opencv2/highgui/highgui_c.h
RUN sed -i '141i#endif' ~/opencv-3.4.1/modules/highgui/include/opencv2/highgui/highgui_c.h

RUN cd ~/opencv-3.4.1/
RUN mkdir build
RUN cd build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-3.4.1/modules \
    -DBUILD_opencv_dnn_modern=OFF \
    -D WITH_CUDA=ON \
    -D CUDA_GENERATION="Pascal" \
    -D CUDA_HOST_COMPILER:FILEPATH=/usr/bin/gcc-5 .. \
    -D BUILD_EXAMPLES=ON ..
RUN make -j8
RUN make install
RUN ldconfig

RUN apt-get -y --quiet install \
		ros-melodic-cv-bridge \
		ros-melodic-gazebo-ros-pkgs

# Create user torch with id 1000 with sudo access
RUN useradd --shell /bin/bash -u 1000 -c "" -m torch && usermod -a -G dialout torch && echo "torch:torch" | chpasswd && adduser torch sudo
RUN sed -i '/force_color_prompt/s/^#//g' ~/.bashrc
RUN sed -i '/force_color_prompt/s/^#//g' /home/torch/.bashrc

# Setup virtual X server
RUN mkdir /tmp/.X11-unix && \
	chmod 1777 /tmp/.X11-unix && \
	chown -R root:root /tmp/.X11-unix
ENV DISPLAY :99

ENV CCACHE_UMASK=000
ENV FASTRTPSGEN_DIR="/usr/local/bin/"
ENV PATH="/usr/lib/ccache:$PATH"
ENV TERM=xterm
ENV TZ=UTC

RUN echo "source /etc/profile.d/bash_completion.sh" >> /home/torch/.bashrc

# Add dynonet package to PTYHONPATH
RUN echo 'export PYTHONPATH=/home/torch/pytorch_ws/dynonet' >> /home/torch/.bashrc 

CMD ["/bin/bash"]
