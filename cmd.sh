#!/bin/sh
postconf -e relayhost="$POSTFIX_RELAY_PORT_25_TCP_ADDR"

# If /etc/nagios3/ is empty (mounted volume), copy the initial nagios config
[ ! "$(ls -A /etc/nagios3/ )" ] && \
cp -R /etc/nagios3init/* /etc/nagios3/

#inotify-hookable -w /etc/nagios3/ -c 'service nagios3 reload && service apache2 reload'

service postfix start

service nagios3 start

service apache2 start