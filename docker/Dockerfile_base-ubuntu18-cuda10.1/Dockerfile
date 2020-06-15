#
# Ubuntu 18 Development Environment
#

FROM nvidia/cudagl:10.1-devel-ubuntu18.04
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y --quiet --no-install-recommends install \
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
	&& apt-get -y autoremove \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# gtest
RUN cd /usr/src/gtest \
	&& mkdir build && cd build \
	&& cmake .. && make \
	&& cp *.a /usr/lib \
	&& cd .. && rm -rf build

RUN python -m pip install --upgrade pip \
	&& pip install setuptools pkgconfig wheel \
	&& pip install argparse argcomplete coverage jinja2 empy numpy requests serial toml pyyaml cerberus


# create arrow with id 1000 with sudo access
RUN useradd --shell /bin/bash -u 1000 -c "" -m arrow && usermod -a -G dialout arrow && echo "arrow:arrow" | chpasswd && adduser arrow sudo
RUN sed -i '/force_color_prompt/s/^#//g' ~/.bashrc
RUN sed -i '/force_color_prompt/s/^#//g' /home/arrow/.bashrc

# setup virtual X server
RUN mkdir /tmp/.X11-unix && \
	chmod 1777 /tmp/.X11-unix && \
	chown -R root:root /tmp/.X11-unix
ENV DISPLAY :99

ENV CCACHE_UMASK=000
ENV FASTRTPSGEN_DIR="/usr/local/bin/"
ENV PATH="/usr/lib/ccache:$PATH"
ENV TERM=xterm
ENV TZ=UTC

RUN echo "source /etc/profile.d/bash_completion.sh" >> /home/arrow/.bashrc

# SITL UDP PORTS
EXPOSE 14556/udp
EXPOSE 14557/udp

CMD ["/bin/bash"]
