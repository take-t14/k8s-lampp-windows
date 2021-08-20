FROM centos:centos7

ENV GOSU_VERSION=1.11
RUN gpg --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu \
    # Verify that the binary works
    && gosu nobody true

ENV MYSQL_MAJOR="5.6"
ENV MYSQL_MINOR="39"
ARG version=${MYSQL_MAJOR}.${MYSQL_MINOR}
RUN yum -y update \
 && yum -y install http://repo.mysql.com/mysql-community-release-el7-7.noarch.rpm \
 && yum -y install yum-utils \
 && yum -y --enablerepo=mysql56-community install mysql-community-server-${version} \
 && yum -y install less \
 && yum clean all

# add conf
RUN rm -f /etc/my.cnf
COPY ./my.cnf /etc/my.cnf
RUN chmod 644 /etc/my.cnf

COPY ./sqls/*.sql /docker-entrypoint-initdb.d/
COPY ./create-volume.sh /usr/local/bin/
RUN chmod 700 /usr/local/bin/create-volume.sh
RUN chown root:root /usr/local/bin/create-volume.sh
COPY ./docker-entrypoint.sh /usr/local/bin/
RUN chmod 777 /usr/local/bin/docker-entrypoint.sh
RUN chown root:root /usr/local/bin/docker-entrypoint.sh

# 言語を日本語に設定
RUN localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
RUN echo 'LANG="ja_JP.UTF-8"' >  /etc/locale.conf
ENV LANG ja_JP.UTF-8

# 日付を日本語に設定
RUN echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock
RUN rm -f /etc/localtime
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/create-volume.sh"]
