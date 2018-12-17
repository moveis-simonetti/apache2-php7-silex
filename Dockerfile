FROM php:7.2-apache

ENV NR_ENABLED=false
ENV NR_APP_NAME=""
ENV NR_LICENSE_KEY=""

RUN docker-php-ext-install pdo_mysql
RUN a2enmod rewrite

RUN apt-get update && apt-get install -y zip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        git \
        libxslt-dev \
        wget \
    && docker-php-ext-install -j$(nproc) iconv zip soap \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \    
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-install -j$(nproc) bcmath

RUN echo "---> Adding Support for NewRelic" && \
    mkdir /tmp/newrelic /scripts/ && \
    cd /tmp/newrelic && \
    wget -r -l1 -nd -A"linux.tar.gz" https://download.newrelic.com/php_agent/release/ && \
    gzip -dc newrelic*.tar.gz | tar xf - && \
    cd newrelic-php5* && \
    rm -f /usr/local/lib/php/extensions/no-debug-non-zts-20170718/newrelic.so && \
    cp ./agent/x64/newrelic-20170718.so /usr/local/lib/php/extensions/no-debug-non-zts-20170718/newrelic.so && \
    cp ./daemon/newrelic-daemon.x64 /usr/bin/newrelic-daemon && \
    cp ./scripts/newrelic.ini.template /scripts/newrelic.ini && \
    mkdir /var/log/newrelic &&  \
    chown -R www-data:www-data /var/log/newrelic && \
    rm -rf /tmp/*

RUN echo "---> Adding Tini" && \
    wget -O /tini https://github.com/krallin/tini/releases/download/v0.18.0/tini-static && \
    chmod +x /tini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

COPY ./provisioning/php.ini /usr/local/etc/php/conf.d/timezone.ini
COPY ./provisioning/apache.conf /etc/apache2/sites-available/000-default.conf

COPY start.sh /usr/bin/start
RUN chmod a+x /usr/bin/start

RUN mkdir -p ~/.ssh/ && ssh-keyscan github.com >> ~/.ssh/known_hosts

EXPOSE 80

CMD ["/tini", "--", "/usr/bin/start"]
