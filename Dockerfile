FROM php:7.1.11-cli

RUN apt-get update && apt-get install -y \
  git \
  curl \
  wget \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libpng12-dev \
  libicu-dev \
  unzip \
  openssh-server \
  software-properties-common \
  sqlite3 \
  libsqlite3-dev \
  bzip2 \
  libxml2-dev \
  php-soap \
  libgmp-dev \
  && docker-php-ext-install -j$(nproc) iconv mcrypt \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd \
  && docker-php-ext-install -j$(nproc) bcmath \
  && docker-php-ext-install -j$(nproc) exif \
  && docker-php-ext-configure intl \
  && docker-php-ext-install intl \
  && docker-php-ext-install zip \
  && docker-php-ext-install pdo pdo_mysql pdo_sqlite \
  && docker-php-ext-install soap \
  && docker-php-ext-install gmp \
  && pecl install xdebug-2.5.0 \
  && docker-php-ext-enable xdebug

ENV JAVA_OPTS -Dfile.encoding=UTF-8 \
              -Dsun.jnu.encoding=UTF-8

COPY php.ini /usr/local/etc/php/

RUN echo "deb http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
RUN echo "deb http://security.debian.org/ jessie/updates main" > /etc/apt/sources.list.d/jessie-updates.list
RUN echo "Acquire::Check-Valid-Until \"false\";" > /etc/apt/apt.conf.d/100disablechecks
RUN apt-get update && apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -t jessie-backports -y openjdk-8-jre-headless ca-certificates-java && update-alternatives --config java

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get install -y nodejs \
  && apt-get install -y build-essential \
  && npm install -g npm yarn gulp-cli @angular/cli apidoc

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN sed -i 's|session required pam_loginuid.so|session optional pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd
RUN adduser --quiet jenkins
RUN chmod 777 /usr/local/lib/php/extensions/no-debug-non-zts-20160303
RUN chmod 777 /usr/local/lib/php/extensions/no-debug-non-zts-20160303/xdebug.so

RUN echo "jenkins:jenkins" | chpasswd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]