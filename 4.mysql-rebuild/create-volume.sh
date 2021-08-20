#!/bin/bash

# ext4の領域作成（ない場合のみ）
if [[ ! -e /mnt/php-apache-psql-data/mysql ]]; then
    INIT=true
fi

rm -rf /var/lib/mysql
ln -s /mnt/php-apache-psql-data /var/lib/mysql
if [[ $INIT ]]; then
    mkdir -p /var/lib/mysql/mysql
    rm -rf /var/lib/mysql/mysql/*
fi

/usr/local/bin/docker-entrypoint.sh mysqld --datadir /var/lib/mysql/mysql --user root
