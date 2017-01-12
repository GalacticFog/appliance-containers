#!/bin/bash

__create_db() {
DB_NAME=$1

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE "$DB_NAME";
    GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" TO "$POSTGRES_USER";
EOSQL
}

# Call all functions
__create_db gestalt-security
__create_db gestalt-meta
__create_db gestalt-lambda
__create_db gestalt-laser
__create_db gestalt-apigateway
__create_db gestalt-kong
