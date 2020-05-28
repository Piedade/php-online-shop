FROM php:7.2-apache

RUN apt-get update \
	&& apt-get install -y \
		libmcrypt-dev \
		libjpeg62-turbo-dev \
		libpcre3-dev \
		libpng-dev \
		libfreetype6-dev \
		libxml2-dev \
		libicu-dev \
		libzip-dev \
    libonig-dev \
		default-mysql-client \
		wget \
		unzip \
		libxslt-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install intl pdo_mysql soap gd zip bcmath xsl sockets

RUN docker-php-source extract \
    && if [ -d "/usr/src/php/ext/mysql" ]; then docker-php-ext-install mysql; fi \
    && if [ -d "/usr/src/php/ext/mcrypt" ]; then docker-php-ext-install mcrypt; fi \
	&& if [ -d "/usr/src/php/ext/opcache" ]; then docker-php-ext-install opcache; fi \
	&& docker-php-source delete

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Define PHP_TIMEZONE env variable
ENV PHP_TIMEZONE Europe/Lisbon

# Install crontab
RUN apt-get update && apt-get -y install cron

# Configure Apache Document Root
ENV APACHE_DOCUMENT_ROOT=/var/www/html
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Increase memory limit
RUN echo 'memory_limit = 1024M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini

# Enable Apache mod_rewrite
RUN a2enmod rewrite


# IF PRESTASHOP
# UPDATE ps_shop_url set domain="localhost", domain_ssl="localhost" where id_shop_url=1