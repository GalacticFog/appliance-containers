#!/bin/bash
set -o errexit

PUBLIC_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
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
#sudo docker-compose up -d --no-recreate security billing dns launcher

echo "> Meta: http://$PUBLIC_HOSTNAME:14374"
