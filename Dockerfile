FROM php:8.0-apache
#install all the dependencies
RUN apt-get update && apt-get install -y \
      libicu-dev \
      libpq-dev \
      git \
      zip \
      unzip \
      zlib1g-dev \
      zlib1g \
      libonig-dev \
    && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-install \
      intl \
      mbstring \
      pcntl \
      pdo_mysql \
      pdo_pgsql \
      pgsql \
      zip \
      opcache
#install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
#create project folder
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
#change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
#change apache setting
RUN sed -i -e "s/var\/www/app/g" /etc/apache2/apache2.conf && sed -i -e "s/html/public/g" /etc/apache2/apache2.conf
RUN a2enmod rewrite
#copy source files and run composer
COPY . $APP_HOME
RUN composer install --no-interaction
#change ownership
RUN chown -R www-data:www-data $APP_HOME