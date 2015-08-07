#!/bin/bash
set -e -x
#echo "starting supervisor in foreground"
if [ ! -z "$LOGSTASH_IP" ] && [ ! -z "$LOGSTASH_HOST" ]; then
    echo "${LOGSTASH_IP} ${LOGSTASH_HOST}" >> /etc/hosts
fi
supervisord -n