#!/bin/bash

cat > ~/.pgpass <<EOF
db:*:*:$DB_USER:$DB_PASS
EOF
chmod 0600 ~/.pgpass

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
#create $BILLING
#create $DNS

#restore $BILLING /tmp/gestaltbilling.pgr
#restore $DNS     /tmp/gestaltdns.pgr
restore $META    /tmp/meta.pgr
