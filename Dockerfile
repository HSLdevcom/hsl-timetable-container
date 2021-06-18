FROM hsldevcom/hsl-map-publisher:production

USER root

WORKDIR /opt/timetable-data-builder

RUN apt-get update && apt-get install -y p7zip-full cron curl jq apt-transport-https ca-certificates gnupg lsb-release && \
 curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
 echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

ADD publisher-scripts /opt/publisher
ADD fonts.zip /opt/publisher/fonts.zip

ADD container-scripts /opt/timetable-data-builder
ADD hsl-timetable-data-container /opt/timetable-data-builder/hsl-timetable-data-container

CMD /opt/timetable-data-builder/startServer.sh && /opt/timetable-data-builder/timetableDataBuilder.sh
