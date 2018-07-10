#!/usr/bin/env bash

if [ -v SLACK_WEBHOOK_URL ]; then
    curl -X POST -H 'Content-type: application/json' \
         --data '{"text":"HSL timetable data build started\n"}' $SLACK_WEBHOOK_URL
fi


./build_timetables.sh
if [ $? -eq 0 ]; then
    if [ -v SLACK_WEBHOOK_URL ]; then
        curl -X POST -H 'Content-type: application/json' \
             --data '{"text":"HSL timetable data build finished\n"}' $SLACK_WEBHOOK_URL
    fi
else
    if [ -v SLACK_WEBHOOK_URL ]; then
        #extract log end which most likely contains info about failure
        { echo -e "HSL timetable data build failed:\n..."; tail -n 40 /cronlogs/cron.log; } | jq -R -s '{text: .}' | \
            curl -X POST -H 'Content-type: application/json' -d@- $SLACK_WEBHOOK_URL
    fi
fi

