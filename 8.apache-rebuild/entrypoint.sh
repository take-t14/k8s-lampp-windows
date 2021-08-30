#!/usr/bin/env bash

/usr/local/bin/entrypoint-setup.sh > /var/log/entrypoint.log 2>&1

cat /var/log/entrypoint.log
exec "$@"
#eval "nohup $@ >> /var/log/entrypoint.log 2>&1 &"
#tail -f /dev/null