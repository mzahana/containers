FROM mzahana/px4-ros-melodic-cuda10.1:latest
LABEL maintainer="Mohamed Abdelkader <mohamedashraf123@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV ARROW_HOME /home/arrow

USER arrow

RUN pip install --upgrade pip
RUN pip3 install torch==1.4.0 torchvision==0.5.0 --no-cache-dir


RUN echo "export PATH=\$PATH:/home/arrow/.local/bin:/home/arrow/.local/bin" >> /home/arrow/.bashrc
RUN echo "export PATH=\$PATH:/usr/local/cuda-10.1/bin" >> /home/arrow/.bashrc
RUN echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/cuda-10.1/lib64:/usr/local/cuda-10.1/targets/x86_64-linux/lib/:/usr/local/cuda/extras/CUPTI/lib64/" >> /home/arrow/.bashrc
RUN echo "export CUDA_HOME=/usr/local/cuda" >> /home/arrow/.bashrc


# Clonning semantic_cloud
RUN cd $ARROW_HOME/catkin_ws/src \
    && git clone https://github.com/TarekTaha/semantic_cloud.git \
    && cd .. \
    && catkin build

# Clonning semantic_based_exploration
RUN cd $ARROW_HOME/catkin_ws/src \
    && git clone https://github.com/kucars/semantic_based_exploration.git \
    && cd semantic_based_exploration \
    && git checkout pre_release \
    && cd install \
    && ./setup_semantic_mapping.sh 1

CMD ["/bin/bash"]