FROM debian:8.1

MAINTAINER Niklas Skoldmark <niklas.skoldmark@gmail.com>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install \
    -y \
#        fusiondirectory-plugin-nagios \
#        fusiondirectory-plugin-nagios-schema \
        ganglia-nagios-bridge \
#        gosa-plugin-nagios \
#        gosa-plugin-nagios-schema \
        inotify-hookable \
        libnagios-object-perl \
        libnagios-plugin-perl \
        nagios-images \
        nagios-nrpe-plugin \
        nagios-nrpe-server \
        nagios-plugin-check-multi \
        nagios-plugins \
        nagios-plugins-basic \
        nagios-plugins-common \
        nagios-plugins-contrib \
        nagios-plugins-rabbitmq \
        nagios-plugins-standard \
        nagios-snmp-plugins \
        nagios2mantis \
        nagios3 \
        nagios3-cgi \
        nagios3-common \
        nagios3-core \
        nagios3-dbg \
        nagios3-doc \
        ndoutils-nagios3-mysql \
        postfix \
        python-nagiosplugin \
        python3-nagiosplugin

RUN htpasswd -bc /etc/nagios3/htpasswd.users nagiosadmin nagiosadmin

# Backup initial /etc/nagios3/
RUN mkdir /etc/nagios3bck && \
    cp -R /etc/nagios3/* /etc/nagios3bck/

#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y fusiondirectory-plugin-nagios fusiondirectory-plugin-nagios-schema

#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y gosa gosa-plugin-nagios gosa-plugin-nagios-schema

VOLUME /etc/nagios3

COPY ["setup.sh", "/srv/setup.sh"]

COPY ["cmd.sh", "/srv/cmd.sh"]

COPY ["entrypoint.sh", "/srv/entrypoint.sh"]

#CMD /srv/cmd.sh

ENTRYPOINT ["/srv/entrypoint.sh"]

EXPOSE 80
