#!/bin/bash

docker run \
  -e JENKINS_URL=https://jenkins.pollen-metrology.com/ \
  -e JENKINS_SECRET=54ca4eb8ab22483fcf6a2dc8525d4dff54640eec5b6f68c61575e65b70a164cd \
  -e JENKINS_AGENT_WORKDIR=/home/jenkins \
  -e JENKINS_NAME=Deep_Learning_cuda_10 \
  -it \
  -d \
  --gpus all \
  --name "deeplearning_cuda_10" \
  --restart always \
  -v /home/docker/deeplearning_cuda_10/jenkins_agent/ws:/home/jenkins \
  -v /home/deeplearning_script/:/home/scripts/ \
  pollenm/deeplearning_cuda_10_0
