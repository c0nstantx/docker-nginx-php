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
ADD ./default.conf.dev /etc/nginx/conf.d/default.conf.dev

# Install PHP 7
 
# Download source and signature
RUN curl -SL "http://php.net/get/php-7.0.0.tar.gz/from/this/mirror" -o php7.tar.gz
RUN curl -SL "http://php.net/get/php-7.0.0.tar.gz.asc/from/this/mirror" -o php7.tar.gz.asc

# Verify file
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763"
RUN gpg --verify php7.tar.gz.asc php7.tar.gz

# Install tools for compile
RUN apt-get install -y build-essential libxml2-dev libcurl4-gnutls-dev libpng-dev libmcrypt-dev libxslt-dev libicu-dev libssl-dev libbz2-dev libjpeg-dev autoconf

# Uncompress
RUN tar zxvf php7.tar.gz

ENV PHP_VERSION 7.0.0

ENV PHP_CLI_INI_DIR /etc/php7/cli
ENV PHP_FPM_INI_DIR /etc/php7/fpm

RUN mkdir -p $PHP_CLI_INI_DIR/conf.d

RUN mkdir -p $PHP_FPM_INI_DIR/conf.d

#php7-cli
RUN cd php-7.0.0 && \
    ./configure \
    --with-config-file-path="$PHP_CLI_INI_DIR" \
    --with-config-file-scan-dir="$PHP_CLI_INI_DIR/conf.d" \
    --with-libdir=/lib/x86_64-linux-gnu \
    --enable-mysqlnd \
    --enable-intl \
    --enable-mbstring \
    --enable-zip \
    --enable-exif \
    --enable-pcntl \
    --enable-bcmath \
    --enable-ftp \
    --enable-exif \
    --enable-calendar \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-wddx \
    --enable-gd-native-ttf \
    --enable-gd-jis-conv \
    --enable-sockets \
    --enable-opcache \
    --enable-sysvsem \
    --enable-sysvshm \
    --with-curl \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-openssl \
    --with-xsl \
    --with-gd \
    --with-mcrypt \
    --with-iconv \
    --with-bz2 \
    --with-mhash \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-zlib && \
    make -j"$(nproc)" && \
    make install && \
    make clean

#php7-fpm
RUN cd php-7.0.0 && \
    ./configure \
    --with-config-file-path="$PHP_FPM_INI_DIR" \
    --with-config-file-scan-dir="$PHP_FPM_INI_DIR/conf.d" \
    --with-libdir=/lib/x86_64-linux-gnu \
    --enable-mysqlnd \
    --enable-intl \
    --enable-mbstring \
    --enable-zip \
    --enable-exif \
    --enable-pcntl \
    --enable-bcmath \
    --enable-ftp \
    --enable-exif \
    --enable-calendar \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-wddx \
    --enable-gd-native-ttf \
    --enable-gd-jis-conv \
    --enable-sockets \
    --enable-opcache \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --with-curl \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-openssl \
    --with-xsl \
    --with-gd \
    --with-mcrypt \
    --with-iconv \
    --with-bz2 \
    --with-mhash \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-zlib && \
    make -j"$(nproc)" && \
    make install && \
    make clean

# Install Xdebug
RUN curl -SL "http://xdebug.org/files/xdebug-2.4.0rc2.tgz" -o xdebug.tgz
RUN tar zxvf xdebug.tgz

RUN cd xdebug-2.4.0RC2 && \
    phpize && \
    ./configure && \
    make && \
    cp modules/xdebug.so /usr/local/lib/php/extensions/no-debug-non-zts-20151012

# Clear files
RUN rm -rf php*
RUN rm -rf xdebug*

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./www.conf /usr/local/etc/php-fpm.conf
ADD ./php.ini /etc/php7/fpm/php.ini
ADD ./php_cli.ini /etc/php7/cli/php.ini
ADD ./php.ini.dev /etc/php7/fpm/php.ini.dev
ADD ./php_cli.ini.dev /etc/php7/cli/php.ini.dev
ADD ./browscap.ini /etc/php7/browscap.ini

# Install logstash forwarder
ADD ./logstash-forwarder_0.4.0_amd64.deb /logstash-forwarder_0.4.0_amd64.deb
RUN dpkg -i logstash-forwarder_0.4.0_amd64.deb
RUN rm /logstash-forwarder_0.4.0_amd64.deb

# Add certificates for development environment
RUN mkdir /etc/nginx/ssl
ADD ./server.crt /etc/nginx/ssl/server.crt
ADD ./server.key /etc/nginx/ssl/server.key

# Setup supervisor
ADD ./supervisord.conf /etc/supervisor/supervisord.conf
ADD ./supervisor_nginx.conf /etc/supervisor/conf.d/supervisor_nginx.conf

RUN service supervisor start

ADD ./start.sh /start.sh

RUN chmod a+x /start.sh

# Define mountable directories.
VOLUME ["/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html", "/usr/local/etc/php"]

ENTRYPOINT ["/start.sh"]
