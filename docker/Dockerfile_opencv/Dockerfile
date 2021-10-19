#
# ROS Melodic + Gazebo 9 + PX4 + OpenCV 3.4.1
#


FROM mzahana/px4-ros-melodic-cuda10.1:latest
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"
USER arrow
ENV DEBIAN_FRONTEND noninteractive
ENV ARROW_HOME /home/arrow
ENV SUDO_PASS arrow
ENV ROS_DISTRO melodic

# Eigen 3.3.7
#  Remove pre-built Eigen
#RUN apt-get remove libeigen3-dev
RUN echo $SUDO_PASS | sudo -S apt update && echo $SUDO_PASS | sudo -S apt install -y unzip 
RUN cd $HOME/src/ &&\
    wget -O eigen.zip https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.zip &&\
    unzip eigen.zip &&\
    mkdir eigen-build && cd eigen-build &&\
    cmake ../eigen-3.3.7/ &&\
    echo $SUDO_PASS | sudo -S make install

# Remove prebuilt opencv
RUN echo $SUDO_PASS | sudo -S apt-get purge -y libopencv* python-opencv 
RUN echo $SUDO_PASS | sudo -S apt-get update &&\
    echo $SUDO_PASS | sudo -S apt-get install -y build-essential pkg-config

RUN echo $SUDO_PASS | sudo -S apt-get install -y cmake libavcodec-dev libavformat-dev libavutil-dev \
    libglew-dev libgtk2.0-dev libgtk-3-dev libjpeg-dev libpng-dev libpostproc-dev \
    libswscale-dev libtbb-dev libtiff5-dev libv4l-dev libxvidcore-dev \
    libx264-dev qt5-default zlib1g-dev libgl1 libglvnd-dev pkg-config \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev mesa-utils     

RUN echo $SUDO_PASS | sudo -S apt-get install -y python2.7-dev python3-dev python-numpy python3-numpy
# it's important to install gcc-5 and use the flag -D CUDA_HOST_COMPILER:FILEPATH=/usr/bin/gcc-5 in opencv cmake command
RUN echo $SUDO_PASS | sudo -S apt install -y gcc-5 g++-5

#
# setup environment
#
ENV CUDA_HOME="/usr/local/cuda"
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

#
# Download & install OpenCV - https://github.com/mdegans/nano_build_opencv/blob/master/build_opencv.sh
#

# OpenCV looks for the cuDNN version in cudnn_version.h, but it's been renamed to cudnn_version_v8.h
#RUN ln -s /usr/include/aarch64-linux-gnu/cudnn_version_v8.h /usr/include/aarch64-linux-gnu/cudnn_version.h

ARG OPENCV_VERSION="3.4.1"
RUN cd $HOME/src/ &&\
    git clone --depth 1 --branch ${OPENCV_VERSION} https://github.com/opencv/opencv.git &&\
    git clone --depth 1 --branch ${OPENCV_VERSION} https://github.com/opencv/opencv_contrib.git && \
    cd opencv && mkdir build && cd build &&\
    cmake   -D CMAKE_BUILD_TYPE=RELEASE \
            -D BUILD_EXAMPLES=OFF \
            -D BUILD_TESTS=OFF \
            -D BUILD_PERF_TESTS=OFF \
            -D CPACK_BINARY_DEB=ON \
            -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
	        -D WITH_EIGEN=ON \
            -D CMAKE_INSTALL_PREFIX=/usr/local \
            -D BUILD_opencv_java=OFF \
            -D WITH_CUDA=ON \
            -D CUDA_ARCH_BIN=6.1 \
            -D CUDA_ARCH_PTX="" \
            -D ENABLE_FAST_MATH=ON \
            -D CUDA_FAST_MATH=ON \
            -D WITH_CUBLAS=ON \
            -D WITH_LIBV4L=ON \
            -D WITH_GSTREAMER=ON \
            -D WITH_GSTREAMER_0_10=OFF \
            -D WITH_QT=ON \
            -D WITH_OPENGL=ON \
            -D WITH_IPP=OFF \
            -D CUDA_NVCC_FLAGS="--expt-relaxed-constexpr" \
            -D WITH_TBB=ON \
            -D CUDA_HOST_COMPILER:FILEPATH=/usr/bin/gcc-5 \
            -D OPENCV_ENABLE_NONFREE=ON \
            -D OPENCV_EXTRA_MODULES_PATH=$HOME/src/opencv_contrib/modules \
            -D BUILD_opencv_python2=ON \
            -D BUILD_opencv_python3=ON \
            ../

RUN cd $HOME/src/opencv/build/ && make -j$(nproc)
RUN cd $HOME/src/opencv/build/ && echo $SUDO_PASS | sudo -S  make install
RUN cd $HOME/src/opencv/build/ && echo $SUDO_PASS | sudo -S make package
RUN cd $HOME/src/opencv/build && tar -czvf OpenCV-${OPENCV_VERSION}-aarch64.tar.gz *.deb

#
# Install cv_bridge from source
#
RUN cd $HOME/catkin_ws/src &&\
    git clone --branch $ROS_DISTRO https://github.com/ros-perception/vision_opencv

# Finally build cv_bridge    
RUN cd $HOME/catkin_ws/ && catkin build
