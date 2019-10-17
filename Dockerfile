# docker build --network=host -t deeplearning_cuda_10_0 .
# docker run -it --gpus all deeplearning_cuda_10_0:latest /bin/bash
#

#docker run \
#  -e JENKINS_URL=https://jenkins.pollen-metrology.com/ \
#  -e JENKINS_SECRET=54ca4eb8ab22483fcf6a2dc8525d4dff54640eec5b6f68c61575e65b70a164cd \
#  -e JENKINS_AGENT_WORKDIR=/home/jenkins_agent/jenkins_cuda_10 \
#  -e JENKINS_NAME=Deep_Learning_cuda_10 \
#  -it \
#  -d \
#  --gpus all \
#  --name "deeplearning_cuda_10" \
#  --restart always \
#  -v /home/docker/deeplearning_cuda_10/jenkins_agent/ws:/home/jenkins_agent/jenkins_cuda_10 \
#  pollenm/deeplearning_cuda_10_0
#
#
#
#  deeplearning_cuda_10_0:latest
#
FROM ubuntu:18.04
#LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"
MAINTAINER Pollen Metrology <admin-team@pollen-metrology.com>

# Config of Jenkins
ARG VERSION=3.28
ARG user=jenkins
ARG group=jenkins
ARG uid=2222

RUN apt-get update && apt-get install -y --no-install-recommends \
gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 10.0.130

ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
cuda-compat-10-0 && \
ln -s cuda-10.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"

# tensorflow-gpu
RUN apt update
RUN apt install -y python3-dev python3-pip
#RUN pip3 install --user --upgrade tensorflow-gpu
RUN pip3 install --upgrade tensorflow-gpu

#libcudnn7
RUN apt-get install libcudnn7=7.6.4.38-1+cuda10.0

# vim
RUN apt-get install -y vim

# test.py
COPY test.py /home/test.py

# install cuda toolkit
RUN apt-get install -y cuda-toolkit-10-0

# Install Jenkins Slave
RUN apt-get install -y --no-install-recommends curl locales sudo && \
    curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar && \
    apt-get purge --autoremove -y curl && \
    chmod 755 /usr/share/jenkins && \
    chmod 644 /usr/share/jenkins/slave.jar

# Add user jenkins to the image
RUN adduser --system --quiet --uid ${uid} --group --disabled-login ${user}

# USER jenkins
RUN echo "${user} ALL = NOPASSWD : /usr/bin/apt-get" >> /etc/sudoers.d/jenkins-can-install 

#RUN mkdir -p /home/pollen && chown jenkins:jenkins /home/pollen && ln -s /home/pollen /pollen


# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV JENKINS_AGENT_WORKDIR=${AGENT_WORKDIR}
ENV JENKINS_AGENT_NAME "NOT SET"
ENV JENKINS_SECRET "NOT SET"
ENV JENKINS_URL "NOT SET"

COPY jenkins-slave.sh /usr/bin/jenkins-slave.sh
#RUN chmod +x /usr/bin/jenkins-slave.sh
RUN chmod 777 /usr/bin/jenkins-slave.sh

ENTRYPOINT ["/usr/bin/jenkins-slave.sh"]
#ENTRYPOINT ["/bin/bash"]