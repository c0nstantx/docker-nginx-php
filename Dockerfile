#
# Rocketgraph web server (nginx)
#

# Pull base image.
FROM nginx:1.9

MAINTAINER Konstantinos Christofilos <kostas.christofilos@rocketgraph.com>

# Install base.
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y curl vim wget && \
  apt-get install -y supervisor

ADD ./default.conf /etc/nginx/conf.d/default.conf
ADD ./default.conf.stage /etc/nginx/conf.d/default.conf.stage

# Install PHP 5.6
RUN \
  apt-get -y update && \
  apt-get -y install php5-cli php5-fpm php5-mysqlnd php5-curl php5-xsl php5-xdebug php5-sqlite php5-intl php5-gd

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./www.conf /etc/php5/fpm/pool.d/www.conf
ADD ./php.ini /etc/php5/fpm/php.ini
ADD ./php_cli.ini /etc/php5/cli/php.ini
ADD ./browscap.ini /etc/php5/browscap.ini

# Install logstash forwarder
ADD ./logstash-forwarder_0.4.0_amd64.deb /logstash-forwarder_0.4.0_amd64.deb
RUN dpkg -i logstash-forwarder_0.4.0_amd64.deb
RUN rm /logstash-forwarder_0.4.0_amd64.deb

# Setup supervisor
ADD ./supervisord.conf /etc/supervisor/supervisord.conf
ADD ./supervisor_nginx.conf /etc/supervisor/conf.d/supervisor_nginx.conf

RUN service supervisor start

ADD ./start.sh /start.sh

RUN chmod a+x /start.sh

# Define mountable directories.
VOLUME ["/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html", "/usr/local/etc/php"]

ENTRYPOINT ["/start.sh"]
