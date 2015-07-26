FROM debian:8.1

MAINTAINER Niklas Skoldmark <niklas.skoldmark@gmail.com>

COPY ["setup.sh", "/srv/setup.sh"]

COPY ["cmd.sh", "/srv/cmd.sh"]

COPY ["entrypoint.sh", "/srv/entrypoint.sh"]

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        apache2 \
        build-essential \
        curl \
        libgd2-xpm-dev \
        libapache2-mod-php5 \
        php5-gd \
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
    make all >> /srv/nagios-make-all && \
    make install >> /srv/nagios-install && \
    make install-init >> /srv/nagios-install-init && \
    make install-config >> /srv/nagios-install-config && \
    make install-commandmode >> /srv/nagios-install-commandmode && \
    make install-webconf >> /srv/nagios-install-webconf && \
    cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/ && \
    chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers && \
    /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg && \
    htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin password && \
    a2enconf nagios.conf

RUN cd /srv && \
    curl -L "http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz" |tar zxvf -

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        dnsutils \
        fping \
        libdbi-dev \
        libmysqlclient-dev \
        libnet-snmp-perl \
        smbclient \
        snmp \
        qstat \
        ssh

# WARNING: install PostgreSQL libs to compile this plugin (see REQUIREMENTS).
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql

# WARNING: install radius libs to compile this plugin (see REQUIREMENTS).
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y libfreeradius-client-dev

# WARNING: install LDAP libs to compile this plugin (see REQUIREMENTS).
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y libldap

# WARNING: OpenSSL or GnuTLS libs could not be found or were disabled
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y openssl
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y gnutls-bin
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y gnutls26-doc

# WARNING: Get lmstat from Globetrotter Software to monitor flexlm licenses

# WARNING: Could not find qmail-qstat or eqivalent

#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y rpcbind

RUN cd /srv/nagios-plugins-* && \
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios && \
    cd /srv/nagios-plugins-* && make >> /srv/nagios-plugins-make && \
    cd /srv/nagios-plugins-* && make install >> /srv/nagios-plugins-make-install

CMD /srv/setup.sh

#ENTRYPOINT ["/srv/entrypoint.sh"]

EXPOSE 80
