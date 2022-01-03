#!/bin/bash

# This script assumes $PWD is the same dir in which this script is located

# Helps avoid permissions problems with `jenkins` user in docker container when
# making a local packaged build
git clean -dfx

# Build .AppImage
docker run -it --rm \
  --cap-add SYS_ADMIN \
  --security-opt apparmor:unconfined \
  --device /dev/fuse \
  -u jenkins:$(getent group $(whoami) | cut -d: -f3) \
  -v "${PWD}:/status-desktop" \
  -w /status-desktop \
  statusteam/nim-status-client-build:latest \
  sh ./scripts/docker-linux.sh pkg-linux
  