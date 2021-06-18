FROM hsldevcom/hsl-map-publisher:production

USER root

WORKDIR /opt/timetable-data-builder

RUN apt-get update && apt-get install -y p7zip-full cron curl jq && \
 curl -O https://download.docker.com/linux/static/stable/x86_64/docker-20.10.7.tgz && \
 tar xzf docker-20.10.7.tgz &&  cp docker/* /usr/bin/ ; rm -rf docker*

ADD publisher-scripts /opt/publisher
ADD fonts.zip /opt/publisher/fonts.zip

ADD container-scripts /opt/timetable-data-builder
ADD hsl-timetable-data-container /opt/timetable-data-builder/hsl-timetable-data-container

CMD /opt/timetable-data-builder/startServer.sh && /opt/timetable-data-builder/timetableDataBuilder.sh
