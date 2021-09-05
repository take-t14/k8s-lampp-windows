FROM centos:centos7

# remi
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && rpm -Uvh https://rpms.remirepo.net/enterprise/remi-release-7.rpm

# normal updates
RUN yum -y update

# php
RUN yum -y install \
  php72 php72-php php72-php-opcache php72-php-bcmath php72-php-cli \
  php72-php-common php72-php-gd php72-php-intl php72-php-json \
  php72-php-mbstring php72-php-pdo php72-php-pdo-dblib \
  php72-php-devel php72-php-pear php72-php-smarty php72-php-pecl-mcrypt \
  php72-php-xmlrpc php72-php-xml php72-php-mysql php72-php-soap \
  php72-php-fpm php72-php-pdo php72-php-pgsql php72-php-pecl-zip \
  php72-php-pecl-mongodb php72-php-pecl-xdebug php72-php-pecl-yaml subversion git \
  ssmtp mailutils gcc-c++ make \
  yum clean all
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash -
RUN yum install -y nodejs \
  yum clean all
RUN rm -rf /var/lib/apt/lists/*
RUN echo "hostname=mail.example.co.jp" > /etc/ssmtp/ssmtp.conf
RUN echo "root=root@mail.example.co.jp" >> /etc/ssmtp/ssmtp.conf
RUN echo "mailhub=postfix-sv" >> /etc/ssmtp/ssmtp.conf
RUN echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
RUN echo "localhost localhost.localdomain" >> /etc/hosts

RUN cp /etc/opt/remi/php72/php.ini /etc/opt/remi/php72/php.ini_org
RUN cp /etc/opt/remi/php72/php-fpm.conf /etc/opt/remi/php72/php-fpm.conf_org
RUN cp -RT /etc/opt/remi/php72/php-fpm.d /etc/opt/remi/php72/php-fpm.d_org
ADD ./php.ini /etc/opt/remi/php72/php.ini
ADD ./php-fpm.conf /etc/opt/remi/php72/php-fpm.conf
ADD ./php-fpm.d/ /etc/opt/remi/php72/php-fpm.d
ADD ./dns-regist.sh /usr/local/bin/
RUN chmod 700 /usr/local/bin/dns-regist.sh
RUN chown root:root /usr/local/bin/dns-regist.sh
ADD ./entrypoint*.sh /usr/local/bin/
RUN chmod 700 /usr/local/bin/entrypoint*.sh
RUN chown root:root /usr/local/bin/entrypoint*.sh

RUN sed -i "s/;date.timezone =/date.timezone = Asia\/Tokyo/" /etc/opt/remi/php72/php.ini

RUN mkdir -p /var/www/html
RUN useradd www-data
RUN echo 'www-data:www-data' |chpasswd
ENV PATH $PATH:/opt/remi/php72/root/usr/sbin:/opt/remi/php72/root/usr/bin:/usr/local/bin

# 言語を日本語に設定
RUN localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
RUN echo 'LANG="ja_JP.UTF-8"' >  /etc/locale.conf
ENV LANG ja_JP.UTF-8

# 日付を日本語に設定
RUN echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock
RUN rm -f /etc/localtime
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# svn設定
RUN mkdir ~/.subversion
RUN echo -e "[global]\nstore-passwords = yes\nstore-auth-creds = yes" > ~/.subversion/config

RUN mv /etc/opt/remi/php72/php.d /etc/opt/remi/php72/php.d_back
RUN mkdir /etc/opt/remi/php72/php.d
RUN cp -a /etc/opt/remi/php72/php.d_back/*opcache*.ini /etc/opt/remi/php72/php.d/
RUN cp -a /etc/opt/remi/php72/php.d_back/*xdebug*.ini /etc/opt/remi/php72/php.d/
RUN cp -a /etc/opt/remi/php72/php.d_back/opcache-default.blacklist /etc/opt/remi/php72/php.d/

RUN cd /tmp/
RUN curl -s https://getcomposer.org/installer | php
RUN mv -i composer.phar /usr/local/bin/composer

RUN chown root:www-data /opt/remi/php72/root/usr/sbin/php-fpm && \
  chmod 775 /opt/remi/php72/root/usr/sbin/php-fpm && \
  mkdir -p /var/opt/remi/php72 && \
  touch /var/opt/remi/php72/stdout && \
  chown -R root:www-data /var/opt/remi/php72 && \
  chmod -R 775 /var/opt/remi/php72 && \
  mkdir -p /var/log/php7
  #mkdir -p /var/opt/remi/php72/stdout && \
  #chown root:www-data /var/opt/remi/php72/stdout && \
  #chmod 660 /var/opt/remi/php72/stdout && \
  #chown root:www-data /var/opt/remi/php72/run/php-fpm && \
  #chmod 775 /var/opt/remi/php72/run/php-fpm

CMD ["php-fpm"]
