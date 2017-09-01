#!/bin/sh
DOCKER_HOST=unix:///var/run/docker.sock
IMAGE=shapigor/swarm-aws-spot-terminator
VERSION=latest
TAG="$IMAGE:$VERSION"
docker build -t $TAG .
docker push $TAG
