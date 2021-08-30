#!/usr/bin/env bash

touch /var/log/entrypoint.log

rm -rf /root/.ssh >> /var/log/entrypoint.log 2>&1
mkdir /root/.ssh >> /var/log/entrypoint.log 2>&1
cp /mnt/ssh/* /root/.ssh/ >> /var/log/entrypoint.log 2>&1
chmod 700 /root/.ssh >> /var/log/entrypoint.log 2>&1
chmod 600 /root/.ssh/* >> /var/log/entrypoint.log 2>&1

/usr/local/bin/dns-regist.sh >> /var/log/entrypoint.log 2>&1

cat /var/log/entrypoint.log
exec "$@"
#eval "nohup $@ >> /var/log/entrypoint.log 2>&1 &"
#tail -f /dev/null