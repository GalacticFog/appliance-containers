#!/bin/bash

DB_USER=${DB_USER:-}
DB_PASS=${DB_PASS:-}
PG_CONFDIR="/var/lib/pgsql/9.4/data"
PGBIN=/usr/pgsql-9.4/bin/postgres

__create_db() {
  DB_NAME=$1
  echo "Creating database \"${DB_NAME}\"..."
  echo "CREATE DATABASE \"${DB_NAME}\";" | \
    sudo -u postgres -H $PGBIN --single \
     -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}

  if [ -n "${DB_USER}" ]; then
    echo "Granting access to database \"${DB_NAME}\" for user \"${DB_USER}\"..."
    echo "GRANT ALL PRIVILEGES ON DATABASE \"${DB_NAME}\" to ${DB_USER};" |
      sudo -u postgres -H $PGBIN --single \
      -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}
  fi
}

__create_user() {
  #Grant rights
  usermod -G wheel postgres

  # Check to see if we have pre-defined credentials to use
if [ -n "${DB_USER}" ]; then
  if [ -z "${DB_PASS}" ]; then
    echo ""
    echo "WARNING: "
    echo "No password specified for \"${DB_USER}\". Generating one"
    echo ""
    DB_PASS=$(pwgen -c -n -1 12)
    echo "Password for \"${DB_USER}\" created as: \"${DB_PASS}\""
  fi
    echo "Creating user \"${DB_USER}\"..."
    echo "CREATE ROLE ${DB_USER} with CREATEROLE login superuser PASSWORD '${DB_PASS}';" |
      sudo -u postgres -H $PGBIN --single \
       -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}
  
fi

}



__run_supervisor() {
supervisord -n
}

# Call all functions
__create_user
__create_db gestalt-security
__create_db gestalt-meta
__create_db gestalt-lambda
__create_db gestalt-apigateway
__create_db gestalt-kong
__run_supervisor

