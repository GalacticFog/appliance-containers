#!/bin/bash

# DBUSER
# DBPASS

cat > ~/.pgpass <<EOF
db:5432:*:$DBUSER:$DBPASS
EOF
chmod 600 ~/.pgpass 

echo "> Creating database 'meta'"
createdb --host=db meta

echo "> Creating database 'gestalt-security'"
createdb --host=db gestalt-security

echo "> Creating database 'gestalt-billing'"
createdb --host=db gestalt-billing

echo "> Creating database 'gestalt-dns'"
createdb --host=db gestalt-dns

