#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
#set -x

if [ $# -lt 3 ]; then 
  echo "usage: [marathon-url] [app-id] [image]"
  exit 1
fi

MARATHON=$1
APPID=$2
NEWIMG=$3

echo querying $APPID at $MARATHON
echo 

http --check-status HEAD $MARATHON/v2/apps/$APPID
current=$(http --check-status GET $MARATHON/v2/apps/$APPID)
echo 
echo Current image: $(echo $current | jq '.app.container.docker.image')
update=$(echo $current | jq ".app.container | .docker.image = \"$NEWIMG\" | { \"container\": {\"docker\": .docker}, \"upgradeStrategy\": { \"minimumHealthCapacity\": 0.0, \"maximumOverCapacity\": 1.0 } }")
echo "Update payload:"
echo $update
echo $update | http --check-status PUT "$MARATHON/v2/apps/$APPID?force=true"
