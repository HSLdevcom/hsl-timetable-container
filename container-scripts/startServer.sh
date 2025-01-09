#!/usr/bin/env bash

cd /opt/publisher
7z x -aoa -p$FONTSTACK_PASSWORD -o/fonts /opt/publisher/fonts.zip
mkdir -p ~/.local/share/fonts/opentype && \
cp /fonts/* ~/.local/share/fonts/opentype && \
fc-cache -f -v && \
mkdir -p ./output
yarn run server &
yarn run worker &
yarn run start &
sleep 60