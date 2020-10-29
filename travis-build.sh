#!/bin/bash
set -e

ORG=${ORG:-hsldevcom}
DOCKER_IMAGE=$ORG/hsl-timetable-builder
DOCKER_TAG="latest"

DOCKER_TAG_LONG=$DOCKER_TAG-$(date +"%Y-%m-%dT%H.%M.%S")-${TRAVIS_COMMIT:0:7}
DOCKER_IMAGE_LATEST=$DOCKER_IMAGE:latest
DOCKER_IMAGE_TAG=$DOCKER_IMAGE:$DOCKER_TAG
DOCKER_IMAGE_TAG_LONG=$DOCKER_IMAGE:$DOCKER_TAG_LONG

docker login -u $DOCKER_USER -p $DOCKER_AUTH
docker build --tag=$DOCKER_IMAGE_TAG_LONG .

if [[ $TRAVIS_PULL_REQUEST == "false" ]] && [[ $TRAVIS_BRANCH == "master" ]]; then
  docker login -u $DOCKER_USER -p $DOCKER_AUTH
  docker push $DOCKER_IMAGE_TAG_LONG
  docker tag $DOCKER_IMAGE_TAG_LONG $DOCKER_IMAGE_LATEST
  docker push $DOCKER_IMAGE_LATEST
fi