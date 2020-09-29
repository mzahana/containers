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
