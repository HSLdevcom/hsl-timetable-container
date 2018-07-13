#!/usr/bin/env bash
printenv | sed 's/^\(.*\)$/export \1/g' > /opt/timetable-data-builder/setEnvs.sh
chmod +x /opt/timetable-data-builder/setEnvs.sh