#!/bin/bash

DBSLEEP=${DBSLEEP:-30}
DBTRIES=${DBTRIES:-10}

cat > ~/.pgpass <<EOF
db:*:*:$DB_USER:$DB_PASS
EOF
chmod 0600 ~/.pgpass

I=$DBTRIES
echo "> Checking DB server state: $I attempts"
until [[ $I -eq 0 ]]; do
    RESP=$(psql --username=gfadmin -w --host=db -l 2>&1)
    SQLSTAT=$?
    if [[ $SQLSTAT -eq 0 ]]; then 
        echo "> Found DB"
        break; 
    fi
    if [[ $SQLSTAT -ne 2 ]]; then 
        echo "> DB test returned $SQLSTAT: $RESP"
        exit $SQLSTAT
    fi
    let I-=1
    if [[ $I -gt 0 ]]; then
        echo "> Failure to contact DB, $I retries left, sleeping $DBSLEEP seconds..."
        sleep $DBSLEEP
    else
        echo "> Failure to contact DB. Quitting now."
        exit $SQLSTAT
    fi
done

restore() {
  echo "> Restoring database $1..."
  pg_restore --username=gfadmin -w --host=db -d $1 $2
}

create() {
  echo "> Creating database '$1'"
  createdb --username=gfadmin --owner=gfadmin -w --host=db $1
}

echo "> Restoring users/groups..."
psql --username=gfadmin -w --host=db -f /tmp/globals.sql $DB_NAME

META=meta
SECURITY=gestalt-security
BILLING=gestalt-billing
DNS=gestalt-dns

create $META
create $SECURITY
create $BILLING
create $DNS

restore $SECURITY  /tmp/gestaltsecurity.pgr
restore $BILLING   /tmp/gestaltbilling.pgr
restore $DNS       /tmp/gestaltdns.pgr
restore $META      /tmp/meta.pgr
