#!/usr/bin/env bash

# Docker version 
docker_V='5:24.0.6-1~ubuntu.22.04~jammy' 
buildx_V='0.23.0-1~ubuntu.22.04~jammy'
compose_V='2.35.1-1~ubuntu.22.04~jammy'

# install & enable docker 
apt-get update 
apt-get install docker-ce=$docker_V \
                docker-ce-cli=$docker_V \
                docker-ce-rootless-extras=$docker_V \
                docker-buildx-plugin=$buildx_V \
                docker-compose-plugin=$compose_V  -y
