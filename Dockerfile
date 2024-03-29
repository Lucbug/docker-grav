FROM php:7.2-apache

# Based on the official Wordpress Dockerfile

RUN a2enmod rewrite expires

# Install PHP extensions
RUN apt-get update && apt-get install -y git libpng-dev libjpeg-dev zlib1g-dev && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mysqli opcache zip mbstring

# Set recommended PHP.ini settings
# See https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
                echo 'upload_max_filesize=25M'; \
        } > /usr/local/etc/php/conf.d/custom-default.ini

ENV GRAV_VERSION 1.6.9
RUN curl -o grav.tar.gz -SL https://github.com/getgrav/grav/archive/${GRAV_VERSION}.tar.gz \
	&& mkdir -p /tmp/grav \
	&& tar -xzf grav.tar.gz -C /tmp \
	&& rsync -a /tmp/grav-${GRAV_VERSION}/ /var/www/html --exclude user \
	&& /var/www/html/bin/grav install \
  && chown -R www-data:www-data /var/www/html \
	&& git config --global user.email "grav@getgrav.org" \
	&& git config --global user.name "grav"

# Comment the following line if you don't want to use Grav's /user directory
COPY user /var/www/html/user

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["bash", "/entrypoint.sh"]
CMD ["apache2-foreground"]
