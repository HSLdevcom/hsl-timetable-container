#!/usr/bin/env bash
set -e

#how often data is built (default once a day)
BUILD_INTERVAL=${BUILD_INTERVAL:-1}
#Substract one day, because first wait hours are computed before each build
BUILD_INTERVAL_SECONDS=$((($BUILD_INTERVAL - 1)*24*3600))
#start build at this time (GMT):
BUILD_TIME=${BUILD_TIME:-23:00:00}

while true; do
    if [[ "$BUILD_INTERVAL" -gt 0 ]]; then
        SLEEP=$(($(date -u -d $BUILD_TIME +%s) - $(date -u +%s) + 1))
        if [[ "$SLEEP" -le 0 ]]; then
            #today's build time is gone, start counting from tomorrow
            SLEEP=$(($SLEEP + 24*3600))
        fi
        SLEEP=$(($SLEEP + $BUILD_INTERVAL_SECONDS))

        echo "Sleeping $SLEEP seconds until the next build ..."
        sleep $SLEEP
    fi

    echo "HSL timetable data build started"
    if [ -v SLACK_WEBHOOK_URL ]; then
        curl -X POST -H 'Content-type: application/json' \
             --data '{"username":"HSL timetable builder","text":"HSL timetable data build started\n"}' $SLACK_WEBHOOK_URL
    fi


    /opt/timetable-data-builder/build_timetables.sh
    SUCCESS=$?
    if [ $SUCCESS -eq 0 ]; then
        echo "HSL timetable data build finished"
        if [ -v SLACK_WEBHOOK_URL ]; then
                { echo -e "HSL timetable data build finished:\n..."; tail -n 1 /tmp/generate.log && tail -n 1 /tmp/fetch.log; } | \
                jq -R -s '{text: .,username:"HSL timetable builder"}' | curl -X POST -H 'Content-type: application/json' -d@- $SLACK_WEBHOOK_URL
        fi
    else
        echo "HSL timetable data build failed"
        if [ -v SLACK_WEBHOOK_URL ]; then
            #extract log end which most likely contains info about failure
            { echo -e "HSL timetable data build failed:\n..."; tail -n 40 /cronlogs/cron.log; } | jq -R -s '{text: .,username:"HSL timetable builder"}' | \
                curl -X POST -H 'Content-type: application/json' -d@- $SLACK_WEBHOOK_URL
        fi
    fi

    if [[ "$BUILD_INTERVAL" -le 0 ]]; then
        #run only once
        exit $SUCCESS
    fi
done