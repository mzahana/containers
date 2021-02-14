FROM mzahana/px4-ros-melodic-cuda10.1:latest
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV ARROW_HOME /home/arrow

USER arrow

RUN pip install --upgrade pip

# Prerequisites for keras-segmentation
RUN pip install opencv-python==4.2.0.32
RUN pip install Keras==2.3.1
RUN pip install launchpadlib==1.10.6
RUN pip install setuptools==41.0.0
RUN pip install tensorflow==2.1.0
RUN pip install cntk
RUN pip install 'scikit-image<0.15'
RUN pip install Theano

RUN echo "arrow" | sudo -S apt-get install -y python-mako libsm6 libxext6 libxrender-dev

RUN if [ ! -d "$ARROW_HOME/src" ]; then \
    mkdir -p $ARROW_HOME/src; fi
RUN cd $ARROW_HOME/src && git clone https://github.com/Theano/libgpuarray.git \
    && cd libgpuarray \
    && git checkout tags/v0.6.5 -b v0.6.9 \
    && mkdir Build \
    && cd Build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make \
    && echo "arrow" | sudo -S make install \
    && cd .. \
    && python setup.py build \
    && python setup.py install \
    $$ echo "arrow" | sudo -S ldconfig

RUN echo "export PATH=\$PATH:/home/arrow/.local/bin:/home/arrow/.local/bin" >> /home/arrow/.bashrc
RUN echo "export PATH=\$PATH:/usr/local/cuda-10.1/bin" >> /home/arrow/.bashrc
RUN echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/cuda-10.1/lib64:/usr/local/cuda-10.1/targets/x86_64-linux/lib/:/usr/local/cuda/extras/CUPTI/lib64/" >> /home/arrow/.bashrc
RUN echo "export CUDA_HOME=/usr/local/cuda" >> /home/arrow/.bashrc

RUN cd $ARROW_HOME/src \
    && git clone https://github.com/divamgupta/image-segmentation-keras \
    && cd image-segmentation-keras \
    && git checkout 6249766 \
    && cd keras_segmentation \
    && sed -i 's/    return pr/    return seg_img/' predict.py \
    && cd .. \
    && echo "arrow" | sudo -S python setup.py install

# Install Pytorch
RUN pip install torch==1.4.0 torchvision==0.5.0 --no-cache-dir
RUN pip3 install torch==1.4.0 torchvision==0.5.0 --no-cache-dir

# Required for semantic_cloud
RUN echo "arrow" | sudo -S apt-get install ros-melodic-jsk-rviz-plugins -y

# Clonning semantic_hazard_cloud
RUN cd $ARROW_HOME/catkin_ws/src \
    && git clone https://github.com/kucars/semantic_hazard_cloud.git \
    && cd .. \
    && catkin build

# Clonning semantic_cloud
RUN cd $ARROW_HOME/catkin_ws/src \
    && git clone https://github.com/TarekTaha/semantic_cloud.git \
    && cd semantic_cloud && mkdir models_trained \
    && cd $ARROW_HOME/catkin_ws \
    && catkin build

# Clonning semantic_based_exploration
RUN cd $ARROW_HOME/catkin_ws/src \
    && git clone https://github.com/kucars/semantic_based_exploration.git \
    && cd semantic_based_exploration \
    && git checkout pre_release \
    && cd install \
    && ./setup_semantic_mapping.sh 1

CMD ["/bin/bash"]