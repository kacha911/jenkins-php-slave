FROM php:7.0.15-cli

RUN apt-get update && apt-get install -y \
  git \
  curl \
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
  && docker-php-ext-install -j$(nproc) iconv mcrypt \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd \
  && docker-php-ext-install -j$(nproc) bcmath \
  && docker-php-ext-install -j$(nproc) exif \
  && docker-php-ext-configure intl \
  && docker-php-ext-install intl \
  && docker-php-ext-install zip \
  && docker-php-ext-install pdo pdo_mysql pdo_sqlite \
  && pecl install xdebug-2.5.0 \
  && docker-php-ext-enable xdebug

RUN echo deb http://http.debian.net/debian jessie-backports main >> /etc/apt/sources.list
RUN apt-get update && apt-get install -t jessie-backports -y openjdk-8-jre-headless ca-certificates-java && update-alternatives --config java

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
  && apt-get install -y nodejs \
  && npm install yarn -g \
  && yarn global add webpack \
  && yarn global add gulp \
  && npm install phantomjs -g \
  && yarn global add karma-phantomjs-launcher

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN sed -i 's|session required pam_loginuid.so|session optional pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd
RUN adduser --quiet jenkins

RUN echo "jenkins:jenkins" | chpasswd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
