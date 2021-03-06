#
# Ubuntu 18 + CUDA 10.1 + OPENGL
#
#FROM nvidia/cuda:10.1-cudnn7-runtime-ubuntu18.04
FROM nvidia/cudagl:10.1-devel-ubuntu18.04
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

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
		python3-dev \
		python3-pip \
		python3-pygments \
		python3-setuptools \
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

# Python 3 dependencies installed by pip
RUN pip3 install argparse argcomplete coverage cerberus empy jinja2 \
		matplotlib==3.0.* numpy pkgconfig pyros-genmsg pyulog pyyaml \
		requests serial toml pyulog wheel


# astyle v2.06
RUN wget -q https://downloads.sourceforge.net/project/astyle/astyle/astyle%202.06/astyle_2.06_linux.tar.gz -O /tmp/astyle.tar.gz \
	&& cd /tmp && tar zxf astyle.tar.gz && cd astyle/src \
	&& make -f ../build/gcc/Makefile && cp bin/astyle /usr/local/bin \
	&& rm -rf /tmp/*

# Gradle (Required to build Fast-RTPS-Gen)
RUN wget -q "https://services.gradle.org/distributions/gradle-5.6.2-bin.zip" -O /tmp/gradle-5.6.2-bin.zip \
	&& mkdir /opt/gradle \
	&& cd /tmp \
	&& unzip -d /opt/gradle gradle-5.6.2-bin.zip \
	&& rm -rf /tmp/*

ENV PATH "/opt/gradle/gradle-5.6.2/bin:$PATH"

# Fast-RTPS
RUN apt install libssl-dev -y
RUN git clone --recursive https://github.com/eProsima/Fast-RTPS.git -b 1.8.x /tmp/FastRTPS-1.8.2 \
	&& cd /tmp/FastRTPS-1.8.2 \
	&& mkdir build && cd build \
	&& cmake -DTHIRDPARTY=ON -DSECURITY=ON .. \
	&& cmake --build . --target install \
	&& rm -rf /tmp/*

# Fast-RTPS-Gen (required since Fast-RTPS-Gen got split from Fast-RTPS repo since 1.8.x)
RUN git clone --recursive https://github.com/eProsima/Fast-RTPS-Gen.git -b v1.0.2 /tmp/Fast-RTPS-Gen \
	&& cd /tmp/Fast-RTPS-Gen \
	&& gradle assemble \
	&& cp share/fastrtps/fastrtpsgen.jar /usr/local/share/fastrtps/ \
	&& cp scripts/fastrtpsgen /usr/local/bin/ \
	&& rm -rf /tmp/*


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

# create and start as LOCAL_USER_ID
#COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
#ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/bin/bash"]
