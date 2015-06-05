#!/bin/bash

cat > ~/.pgpass <<EOF
db:*:*:$DB_USER:$DB_PASS
EOF
chmod 0600 ~/.pgpass

echo "> Creating database 'meta'"
createdb --username=gfadmin -w --host=db meta

echo "> Creating database 'gestalt-security'"
createdb --username=gfadmin -w --host=db gestalt-security

echo "> Creating database 'gestalt-billing'"
createdb --username=gfadmin -w --host=db gestalt-billing

echo "> Creating database 'gestalt-dns'"
createdb --username=gfadmin -w --host=db gestalt-dns

