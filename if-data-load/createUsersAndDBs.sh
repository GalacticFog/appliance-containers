#!/bin/bash

cat > ~/.pgpass <<EOF
db:*:*:$DB_USER:$DB_PASS
EOF
chmod 0600 ~/.pgpass

restore() {
  echo "> Restoring $1 database..."
  pg_restore -d $1 $2
  rm $2
}

create() {
  echo "> Creating database 'gestalt-dns'"
  createdb --username=gfadmin -w --host=db $1
}

echo "> Restoring users/groups..."
psql -f /tmp/globals.sql $DB_NAME

META=meta
SECURITY=gestalt-security
BILLING=gestalt-billing
DNS=gestalt-dns

create $META
create $SECURITY
create $BILLING
create $DNS

restore $BILLING /tmp/gestaltbilling.pgr
restore $DNS     /tmp/gestaltdns.pgr
