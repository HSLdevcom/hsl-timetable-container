#!/usr/bin/env bash
set -e

DATE=`date +"%Y-%m-%d"`

ORG=${ORG:-hsldevcom}
CONTAINER=hsl-timetable-container
DOCKER_IMAGE=$ORG/$CONTAINER
DOCKER_CUSTOM_IMAGE_TAG=$DOCKER_IMAGE:$DOCKER_TAG
DOCKER_DATE_IMAGE=$DOCKER_IMAGE:$DATE-$DOCKER_TAG

export DOCKER_API_VERSION=1.23

cd /opt/publisher
./generate.sh | tee /tmp/generate.log

cp -r /opt/publisher/output/. /opt/timetable-data-builder/hsl-timetable-data-container/output/
cd /opt/timetable-data-builder/hsl-timetable-data-container

echo "Tagging as $DOCKER_CUSTOM_IMAGE_TAG"
docker build -t $DOCKER_CUSTOM_IMAGE_TAG -f Dockerfile.data-container .

if [ -v DOCKER_TAG ] && [ "$DOCKER_TAG" != "undefined" ]; then
    docker login -u $DOCKER_USER -p $DOCKER_AUTH

    docker tag $DOCKER_CUSTOM_IMAGE_TAG $DOCKER_DATE_IMAGE

    docker push $DOCKER_DATE_IMAGE
    echo "HSL timetable container pushed as $DOCKER_DATE_IMAGE"

    docker push $DOCKER_CUSTOM_IMAGE_TAG
    echo "HSL timetable container pushed as $DOCKER_CUSTOM_IMAGE_TAG"
else
    echo "No tag defined"
fi





