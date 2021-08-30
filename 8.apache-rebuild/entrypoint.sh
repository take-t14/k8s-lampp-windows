#!/usr/bin/env bash

touch /var/log/entrypoint.log

ln -s /mnt/src/example1.co.jp /home/example1.co.jp >> /var/log/entrypoint.log 2>&1
ln -s /mnt/src/example2.co.jp /home/example2.co.jp >> /var/log/entrypoint.log 2>&1
ln -s /mnt/src/laravel-ddd-sample /home/laravel-ddd-sample >> /var/log/entrypoint.log 2>&1

cat /var/log/entrypoint.log
exec "$@"
#eval "nohup $@ >> /var/log/entrypoint.log 2>&1 &"
#tail -f /dev/null