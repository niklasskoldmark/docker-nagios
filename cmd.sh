#!/bin/sh
postconf -e relayhost="$POSTFIX_RELAY_PORT_25_TCP_ADDR"
service postfix start
/etc/init.d/nagios start && \
service apache2 start