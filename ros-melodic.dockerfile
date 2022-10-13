# docker build -f ros-melodic.dockerfile -t eehantiming/ouster_slam:1.0 .
# start container with ./run.sh

FROM osrf/ros:melodic-desktop-full
SHELL ["/bin/bash", "-c"]

## GPU/ display support
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,graphics,utility

RUN apt-get update && apt-get install -y \
  vim \
  tmux \
  wget \
  unzip \
  libparmetis-dev \
  libeigen3-dev \
  libfmt-dev \
  libgoogle-glog-dev \
  libgflags-dev \
  libatlas-base-dev \
  libsuitesparse-dev \
  libparmetis-dev \
  build-essential \ 
  libeigen3-dev \
  libjsoncpp-dev \
  ros-melodic-pcl-ros \
  pcl-tools \
  ros-melodic-eigen-conversions \
  ros-melodic-mavros ros-melodic-mavros-extras \
&& rm -rf /var/lib/apt/lists/*

ARG GITHUB_PAT

RUN mkdir -p ~/thirdparty-software 
WORKDIR /root/thirdparty-software 

# SuperOdometry
## Ceres Solver
RUN git clone https://ceres-solver.googlesource.com/ceres-solver \
  && cd ceres-solver \
  && mkdir build && cd build \
  && cmake .. -DBUILD_TESTING=OFF -DBUILD_DOCUMENTATION=OFF -DBUILD_EXAMPLES=OFF -DBUILD_BENCHMARKS=OFF -DPROVIDE_UNINSTALL_TARGET=OFF \
  && sudo make install -j8 \
  && sudo rm -rf ~/thirdparty-software/ceres-solver

## Sophus
RUN git clone http://github.com/strasdat/Sophus.git \
  && cd Sophus && git checkout 97e7161 \
  && mkdir build && cd build && cmake .. -DBUILD_TESTS=OFF \
  && make -j8 && sudo make install \
  && sudo rm -rf ~/thirdparty-software/Sophus

## GTSAM
RUN git clone https://github.com/borglab/gtsam.git --branch 4.0.2 \
  && cd gtsam \
  && mkdir build && cd build \
  && cmake -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF -DGTSAM_BUILD_TESTS=OFF -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF ..\
  && sudo make install -j8 \
  && cd ~ \
  && sudo rm -rf ~/thirdparty-software/gtsam

## Superodometry package
COPY ./airlab-superodometry.deb /root/thirdparty-software 
RUN sudo dpkg -i airlab-superodometry.deb \
  && sudo rm ./airlab-superodometry.deb


# Ouster Driver
RUN mkdir -p ~/ros_ws/src
WORKDIR /root/ros_ws/src

RUN git clone https://github.com/ouster-lidar/ouster_example
RUN touch /root/ros_ws/src/ouster_example/test.json


# FAST-LIO
## Livox SDK
RUN git clone --single-branch --branch master https://$GITHUB_PAT@github.com/Livox-SDK/Livox-SDK.git \
  && cd Livox-SDK \
  && cd build && cmake .. \
  && make \
  && make install 

## Livox ros driver
RUN git clone https://$GITHUB_PAT@github.com/Livox-SDK/livox_ros_driver.git \
  && cd .. \
  && source /opt/ros/melodic/setup.bash \
  && source /opt/airlab/superodometry/setup.bash \
  && catkin_make

## FAST-LIO package
RUN git clone --single-branch --branch main https://$GITHUB_PAT@github.com/DinoHub/FAST_LIO.git \
  && cd .. \
  && source devel/setup.bash \
  && catkin_make


# Other Sensors
## px4

## xsens
COPY ./xsens_ros_mti_driver /root/ros_ws/src/xsens_ros_mti_driver
RUN cd xsens_ros_mti_driver/lib/xspublic \
  && make \
  && cd /root/ros_ws \
  && source devel/setup.bash \
  && catkin_make

# Other set ups
COPY ./configs/ /root/

## Set up bashrc
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN echo "source ~/.docker-prompt" >> ~/.bashrc
RUN echo "source ~/ros_ws/devel/setup.bash" >> ~/.bashrc

WORKDIR /root/

# Entrypoint