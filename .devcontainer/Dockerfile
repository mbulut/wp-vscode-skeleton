# We don't inherit from offical WP image becase it has a VOLUME that causes issues
FROM php:8.1-apache

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Enable .htaccess files & mod_rewrite
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/apache2/apache2.conf
RUN a2enmod rewrite

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends ghostscript git less ssh-client mariadb-client; \
	rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - ; \
	apt-get install -y nodejs; \
	rm -rf /var/lib/apt/lists/*;

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
		libzip-dev; \
	rm -rf /var/lib/apt/lists/*
	
RUN	docker-php-ext-configure gd --with-freetype --with-jpeg; \
	docker-php-ext-install -j "$(nproc)" \
		bcmath \
		exif \
		gd \
		mysqli \
		opcache \
		zip
		
RUN	pecl install imagick xdebug \
	&& docker-php-ext-enable imagick xdebug

COPY php-conf.d/*.ini /usr/local/etc/php/conf.d/

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

WORKDIR /tmp
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
		&& php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer

RUN useradd -ms /bin/bash vscode \
	&& usermod -aG www-data vscode

RUN { \
	echo "alias l='ls -1'"; \
	echo "alias la='ls -al'"; \
	echo "alias ll='ls -l'"; \
} >>/home/vscode/.bashrc

RUN curl https://raw.githubusercontent.com/wp-cli/wp-cli/v2.7.1/utils/wp-completion.bash >>/home/vscode/.bashrc
