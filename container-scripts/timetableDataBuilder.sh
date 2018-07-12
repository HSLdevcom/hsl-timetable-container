#!/usr/bin/env bash
set -e

echo "HSL timetable data build started"
if [ -v SLACK_WEBHOOK_URL ]; then
    curl -X POST -H 'Content-type: application/json' \
         --data '{"username":"HSL timetable builder","text":"HSL timetable data build started\n"}' $SLACK_WEBHOOK_URL
fi


/opt/timetable-data-builder/build_timetables.sh
if [ $? -eq 0 ]; then
    echo "HSL timetable data build finished"
    if [ -v SLACK_WEBHOOK_URL ]; then
            { echo -e "HSL timetable data build finished:\n..."; tail -n 1 /tmp/generate.log; } | jq -R -s '{text: .,username:"HSL timetable builder"}' | \
            curl -X POST -H 'Content-type: application/json' -d@- $SLACK_WEBHOOK_URL
    fi
else
        echo "HSL timetable data build failed"
    if [ -v SLACK_WEBHOOK_URL ]; then
        #extract log end which most likely contains info about failure
        { echo -e "HSL timetable data build failed:\n..."; tail -n 40 /cronlogs/cron.log; } | jq -R -s '{text: .,username:"HSL timetable builder"}' | \
            curl -X POST -H 'Content-type: application/json' -d@- $SLACK_WEBHOOK_URL
    fi
fi

