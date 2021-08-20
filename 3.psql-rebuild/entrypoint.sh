#!/usr/bin/env bash

if [ -z "$(ls -A $PGDATA)" ]; then
    mkdir -p "$PGDATA"
    chown -R postgres "$PGDATA"
    chmod 700 "$PGDATA"
    initdb -E UTF8 --locale=C
    pg_ctl -w start
    echo
    for f in /init/sqls/*; do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *.sql)    echo "$0: running $f"; "${psql[@]}" -f "$f"; echo ;;
            *.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${psql[@]}"; echo ;;
            *)        echo "$0: ignoring $f" ;;
        esac
        echo
    done
    pg_ctl -w stop
fi

exec "$@"