FROM nvidia/cuda:11.2.2-cudnn8-runtime-ubuntu20.04

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG ssh_prv_key
ARG ssh_pub_key

RUN apt-get update && \
    apt-get install -y \
        git \
        openssh-server \
        libmysqlclient-dev

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# Add the keys and set permissions
RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV USER=peract HOME=/home/peract
ENV ROS_WS=$HOME/ros_ws
ENV DEV_WS=$HOME/dev_ws

RUN echo "The working directory is: $HOME"
RUN echo "The user is: $USER"

RUN mkdir -p $DEV_WS
RUN mkdir -p $ROS_WS

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        make \
        automake \
        autoconf \
        libtool \
        pkg-config \
        python \
        libxext-dev \
        libx11-dev \
        x11proto-gl-dev \
        liblua5.1-0-dev \
        liblua5.1-0 \
        qtbase5-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev && \
    rm -rf /var/lib/apt/lists/*


RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential cmake doxygen g++ git octave python-dev python-setuptools wget mlocate python2 curl qt5-default minizip python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ["/bin/bash", "-c", \
     "cd $DEV_WS && git clone https://github.com/stepjam/PyRep.git"]

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*

RUN ["/bin/bash", "-c", "cd $DEV_WS && wget https://www.coppeliarobotics.com/files/V4_1_0/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz && tar -xvf CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz"]

ENV COPPELIASIM_ROOT=$DEV_WS/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$COPPELIASIM_ROOT
ENV QT_QPA_PLATFORM_PLUGIN_PATH=$COPPELIASIM_ROOT

RUN ["/bin/bash", "-c", "cd $DEV_WS/PyRep && pip3 install -r requirements.txt && pip3 install ."]
