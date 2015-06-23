#!/bin/bash
set -o errexit
set -o nounset

usage() {
  echo "$1"
  echo "usage: $0 <public-hostname> <configuration file>"
  exit 1
}

if [ $# -ne 2 ]; then 
  usage "Missing arguments"
fi
PUBLIC_HOSTNAME=$1
CONF="$2"
if [ ! -f "$CONF" ]; then 
  usage "Configuration file does not exist: $CONF"
fi

echo "> PUBLIC_HOSTNAME=$PUBLIC_HOSTNAME"

for f in "docker-compose" "meta"; do 
  echo "> Updating PUBLIC_HOSTNAME in $f"
  sed "s/PUBLIC_HOSTNAME/$PUBLIC_HOSTNAME/g" $f.template.yml > $f.yml
done

# db, zookeeper and kafka
sudo docker-compose up -d --no-recreate db zookeeper kafka
# restore DB
sudo docker-compose up    --no-recreate ifDataLoad   # this will block while completing
sudo docker-compose up -d --no-recreate meta
# deploy blueprint in meta, parse topology, set config
sudo docker-compose up    --no-recreate ifConfigTask # this will block while completing
sudo docker-compose up -d --no-recreate security
#sudo docker-compose up -d --no-recreate billing dns launcher

echo "> Meta: http://$PUBLIC_HOSTNAME:14374"
