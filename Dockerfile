FROM hsl-map-publisher

USER root

WORKDIR /opt/timetable-data-builder

ADD https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz /opt/timetable-data-builder
RUN cd /opt/timetable-data-builder ; tar xzf docker-18.03.1-ce.tgz ; cp docker/* /usr/bin/ ; rm -rf docker*

VOLUME /cronlogs

RUN apt-get update && apt-get install -y p7zip-full cron

ADD publisher-scripts /opt/publisher
ADD fonts.zip /opt/publisher/fonts.zip

ADD container-scripts /opt/timetable-data-builder
ADD hsl-timetable-data-container /opt/timetable-data-builder/hsl-timetable-data-container

ADD timetable-builder.cron /etc/cron.d/timetable-builder
RUN chmod 0644 /etc/cron.d/timetable-builder

CMD touch /cronlogs/cron.log && cron && tail -f /cronlogs/cron.log
#CMD ["/opt/timetable-data-builder/build_timetables.sh"]