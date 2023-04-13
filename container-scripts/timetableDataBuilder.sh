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
    if [ -n "${SLACK_CHANNEL_ID}" ]; then
        MSG='{"channel": "'$SLACK_CHANNEL_ID'", "text":"HSL timetable build started", "username": "HSL timetable builder"}'
        TIMESTAMP=$(curl -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $SLACK_ACCESS_TOKEN" -H 'Accept: */*' \
          -d "$MSG" 'https://slack.com/api/chat.postMessage' | jq -r .ts)
    fi

    SUCCESS=$?
    if [ $SUCCESS -eq 0 ]; then
        echo "HSL timetable data build finished"
        if [ -n "${SLACK_CHANNEL_ID}" ]; then
            MSG=$({ echo -e "HSL timetable data build finished :white_check_mark:\n"; tail -n 1 /tmp/generate.log && tail -n 1 /tmp/fetch.log; } | \
		jq -R -s '{"channel": "'$SLACK_CHANNEL_ID'", "username": "HSL timetable builder", "thread_ts": "'$TIMESTAMP'", "text": .}')
            curl -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $SLACK_ACCESS_TOKEN" -H 'Accept: */*' -d "$MSG" 'https://slack.com/api/chat.update'
        fi
    else
        echo "HSL timetable data build failed"
        if [ -n "${SLACK_CHANNEL_ID}" ]; then
            #extract log end which most likely contains info about failure
            MSG=$({ echo -e "Dataloading log: \n"; tail -n 40 /cronlogs/cron.log; } | jq -R -s '{"channel": "'$SLACK_CHANNEL_ID'", "username": "HSL timetable builder", "thread_ts": "'$TIMESTAMP'", "text": .}')
            curl -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $SLACK_ACCESS_TOKEN" -H 'Accept: */*' -d "$MSG" 'https://slack.com/api/chat.postMessage'

            MSG='{"channel": "'$SLACK_CHANNEL_ID'", "text": "HSL timetable build failed :boom:", "username": "HSL timetable builder", "ts": "'$TIMESTAMP'"}'
            curl -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $SLACK_ACCESS_TOKEN" -H 'Accept: */*' -d "$MSG" 'https://slack.com/api/chat.update'
        fi
    fi

    if [[ "$BUILD_INTERVAL" -le 0 ]]; then
        #run only once
        exit $SUCCESS
    fi
done
