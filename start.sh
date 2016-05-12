#!/bin/bash
set -e -x
#echo "starting supervisor in foreground"
if [ ! -z "$LOGSTASH_IP" ] && [ ! -z "$LOGSTASH_HOST" ]; then
    echo "${LOGSTASH_IP} ${LOGSTASH_HOST}" >> /etc/hosts
fi
if [ "$ENVIRONMENT" == "stage" ]; then
    cp /etc/nginx/conf.d/default.conf.stage /etc/nginx/conf.d/default.conf
    cp /etc/php7/fpm/php.ini.stage /etc/php7/fpm/php.ini
    cp /etc/php7/cli/php.ini.stage /etc/php7/cli/php.ini
elif [ "$ENVIRONMENT" == "stage_non_restricted" ]; then
    cp /etc/nginx/conf.d/default.conf.stage_non_restricted /etc/nginx/conf.d/default.conf
    cp /etc/php7/fpm/php.ini.dev /etc/php7/fpm/php.ini
    cp /etc/php7/cli/php.ini.dev /etc/php7/cli/php.ini
elif [ "$ENVIRONMENT" == "dev" ]; then
    cp /etc/nginx/conf.d/default.conf.dev /etc/nginx/conf.d/default.conf
    cp /etc/php7/fpm/php.ini.dev /etc/php7/fpm/php.ini
    cp /etc/php7/cli/php.ini.dev /etc/php7/cli/php.ini
fi
/usr/local/sbin/php-fpm
supervisord -n
