#!/usr/bin/env bash
set -e

SLACKUSER='HSL timetable builder'
SLACKPOSTURL='https://slack.com/api/chat.postMessage'
SLACKUPDATEURL='https://slack.com/api/chat.update'

# param1: slack message
# param2: slack url
function slackpost {
    curl -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $SLACK_ACCESS_TOKEN" -H 'Accept: */*' -d "$1" "$2"
}

echo "$SLACKUSER started"
if [ -n "${SLACK_CHANNEL_ID}" ]; then
    MSG='{"channel": "'$SLACK_CHANNEL_ID'", "text":"'$SLACKUSER' started", "username": "'$SLACKUSER'"}'
    TIMESTAMP=$(slackpost "$MSG" "$SLACKPOSTURL" | jq -r .ts)
fi

/opt/timetable-data-builder/build_timetables.sh
SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
    echo "$SLACKUSER finished"
    if [ -n "${SLACK_CHANNEL_ID}" ]; then
        MSG=$({ tail -n 1 /tmp/generate.log && tail -n 1 /tmp/fetch.log; } | jq -R -s '{"channel": "'$SLACK_CHANNEL_ID'", "username": "'"$SLACKUSER"'", "thread_ts": "'$TIMESTAMP'", "text": .}')
        slackpost "$MSG" "$SLACKPOSTURL"

	MSG='{"channel": "'$SLACK_CHANNEL_ID'","text": "'$SLACKUSER' finished :white_check_mark:", "username": "'$SLACKUSER'", "ts": "'$TIMESTAMP'"}';
	slackpost "$MSG" "$SLACKUPDATEURL"
    fi
else
    echo "$SLACKUSER failed"
    if [ -n "${SLACK_CHANNEL_ID}" ]; then
        #extract log end which most likely contains info about failure
        MSG=$({ echo -e "Dataloading log: \n"; tail -n 40 /cronlogs/cron.log; } | jq -R -s '{"channel": "'$SLACK_CHANNEL_ID'", "username": "'"$SLACKUSER"'", "thread_ts": "'$TIMESTAMP'", "text": .}')
	slackpost "$MSG" "$SLACKPOSTURL"

        MSG='{"channel": "'$SLACK_CHANNEL_ID'", "text": "'$SLACKUSER' failed :boom:", "username": "'$SLACKUSER'", "ts": "'$TIMESTAMP'"}'
	slackpost "$MSG" "$SLACKUPDATEURL"
    fi
fi
