#!/bin/bash
set -e -x
#echo "starting supervisor in foreground"
if [ ! -z "$LOGSTASH_URI" ] && [ ! -z "$LOGSTASH_HOST" ]; then
    echo "${LOGSTASH_URI} ${LOGSTASH_HOST}" >> /etc/hosts
fi
supervisord -n