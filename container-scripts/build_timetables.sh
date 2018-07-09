#!/usr/bin/env bash

cd /opt/publisher
unzip /opt/publisher/fonts.zip -d /fonts
./generate.sh

cp -r /opt/publisher/output /opt/timetable-data-builder/hsl-timetable-data-container/output
cd /opt/timetable-data-builder/hsl-timetable-data-container
docker build -t hsl-timetable-container -f Dockerfile.data-container .