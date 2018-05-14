FROM tomcat:7-jre7
# ^^^ set base image

# set base directory to be used in other instructions
WORKDIR ${CATALINA_HOME}

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get install -y build-essential curl zip unzip cron software-properties-common supervisor

# Copy Supervisor config
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY exit-event-listener /usr/local/bin/

# Copy WAR to Tomcat
RUN rm -rf -- webapps/*
COPY ./ROOT.war webapps/

# Add cron task
COPY crontab.txt .
COPY cronscript.sh .
RUN touch logs/cron.logexit-event-listenerexit-event-listener
RUN /usr/bin/crontab crontab.txt

# expose tomcats' port
EXPOSE 8080

# Start main process
CMD ["/usr/bin/supervisord"]