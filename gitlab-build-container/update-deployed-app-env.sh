#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
#set -x

if [ $# -lt 4 ]; then 
  echo "usage: [marathon-url] [app-id] [key=value]..."
  exit 1
fi

MARATHON=$1
APPID=$2
shift; shift;

echo querying $APPID at $MARATHON
echo 

http --check-status HEAD $MARATHON/v2/apps/$APPID
app=$(http --check-status GET $MARATHON/v2/apps/$APPID | jq '{"env": .app.env}')

echo Current environment variables:
echo $app | jq '.'

while (( "$#" )); do 
  IFS="=" read -ra KV <<< "$1"
  shift
  KEY=${KV[0]}
  VAL=${KV[1]}
  echo Current value for env var $KEY: $(echo $app | jq -r ".env.$KEY")
  echo "Setting $KEY -> $VAL"
  app=$(echo $app | jq ".env.$KEY = \"$VAL\" | {\"env\": .env}")
done

echo "Update payload:"
echo $app | jq '.'
echo $app | http --check-status PUT $MARATHON/v2/apps/$APPID
