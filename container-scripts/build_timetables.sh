#!/usr/bin/env bash
set -e

ORG=${ORG:-hsldevcom}
DOCKER_IMAGE=$ORG/hsl-timetable-container

DOCKER_TAG_LONG=$DOCKER_TAG-$(date +"%Y-%m-%dT%H.%M.%S")
DOCKER_IMAGE_LATEST=$DOCKER_IMAGE:latest
DOCKER_IMAGE_TAG=$DOCKER_IMAGE:$DOCKER_TAG
DOCKER_IMAGE_TAG_LONG=$DOCKER_IMAGE:$DOCKER_TAG_LONG

cd /opt/publisher
./generate.sh | tee /tmp/generate.log
./fetch.sh | tee /tmp/fetch.log

cp -r /opt/publisher/output/. /opt/timetable-data-builder/hsl-timetable-data-container/output-stops/
cp -r /opt/publisher/output-routes/. /opt/timetable-data-builder/hsl-timetable-data-container/output-routes/

cd /opt/timetable-data-builder/hsl-timetable-data-container

echo "Tagging as $DOCKER_IMAGE_TAG_LONG"
docker login -u $DOCKER_USER -p $DOCKER_AUTH
docker build -t $DOCKER_IMAGE_TAG_LONG -f Dockerfile.data-container .

if [ -v DOCKER_TAG ] && [ "$DOCKER_TAG" != "undefined" ]; then
    docker login -u $DOCKER_USER -p $DOCKER_AUTH

    docker tag $DOCKER_IMAGE_TAG_LONG $DOCKER_IMAGE_TAG

    docker push $DOCKER_IMAGE_TAG_LONG
    echo "HSL timetable container pushed as $DOCKER_IMAGE_TAG_LONG"

    docker push $DOCKER_IMAGE_TAG
    echo "HSL timetable container pushed as $DOCKER_IMAGE_TAG"
else
    echo "No tag defined"
fi





