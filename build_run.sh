#!/usr/bin/env bash

DOCKER_DIR=.
DOCKER_TAG=mytestapp

# build docker container
docker build -t ${DOCKER_TAG} ${DOCKER_DIR}

# run built container
## --rm - Automatically remove the container when it exits
## --tty , -t - Allocate a pseudo-TTY
## --interactive , -i - Keep STDIN open even if not attached
docker run --rm -e "JAVA_OPTS=-Xmx1g -Xms512M -XX:MaxPermSize=1024m -Dstringchararrayaccessor.disabled=true" \
        -it -p 8080:8080 ${DOCKER_TAG}