#!/bin/bash

DB_USER=${DB_USER-}
DB_PASS=${DB_PASS-}

__create_db() {
DB_NAME=$1

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE "$DB_NAME";
    GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" TO "$DB_USER";
EOSQL
}

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER "$DB_USER" WITH PASSWORD '$DB_PASS';
EOSQL

# Call all functions
__create_db gestalt-security
__create_db gestalt-meta
__create_db gestalt-lambda
__create_db gestalt-apigateway
__create_db gestalt-kong
