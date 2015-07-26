FROM debian:8.1

MAINTAINER Niklas Skoldmark <niklas.skoldmark@gmail.com>

COPY ["setup.sh", "/srv/setup.sh"]

COPY ["cmd.sh", "/srv/cmd.sh"]

COPY ["entrypoint.sh", "/srv/entrypoint.sh"]

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    curl \
    build-essential \
    apache2 \
    php5-gd \
    libgd2-xpm-dev \
    libapache2-mod-php5 \
    postfix

RUN cd /srv && \
    curl -L "http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.0.8.tar.gz" |tar zxvf - && \
    useradd nagios && \
    groupadd nagcmd && \
    usermod -a -G nagcmd nagios && \
    cd /srv/nagios-* && \
    ./configure \
        --with-nagios-group=nagios \
        --with-command-group=nagcmd \
        --with-mail=/usr/sbin/postfix \
        --with-httpd-conf=/etc/apache2/conf-available && \
    make all && \
    make install && \
    make install-init && \
    make install-config && \
    make install-commandmode && \
    make install-webconf && \
    cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/ && \
    chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers && \
    /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg && \
    htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin password && \
    a2enconf nagios.conf

RUN cd /srv && \
    curl -L "http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz" |tar zxvf - && \
    cd /srv/nagios-plugins-* && \
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios && \
    make && \
    make install

EXPOSE 80
