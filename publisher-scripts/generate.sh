#!/bin/bash
set -e

mkdir -p ~/.local/share/fonts/opentype && \
cp /fonts/* ~/.local/share/fonts/opentype && \
fc-cache -f -v && \
mkdir -p ./output && \
node_modules/.bin/forever start -c "yarn serve" ./ && \
sleep 10 && \
time node generateStopsPdf.js