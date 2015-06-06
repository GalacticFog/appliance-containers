#!/bin/bash

PUBLIC_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
echo "> PUBLIC_HOSTNAME=$PUBLIC_HOSTNAME"

for f in "docker-compose" "meta"; do 
  echo "> Updating PUBLIC_HOSTNAME in $f"
  sed "s/PUBLIC_HOSTNAME/$PUBLIC_HOSTNAME/g" $f.template.yml > $f.yml
done

# deploy appliance blueprint

docker-compose up -d --no-recreate db zookeeper kafka
# restore DB
sudo docker-compose up --no-recreate ifDataLoad
docker-compose up -d --no-recreate meta
# deploy blueprint in meta, parse topology, set config
#docker-compose up --no-recreate ifConfigTask
#sudo docker-compose up -d --no-recreate security billing dns launcher

echo "> Meta: http://$PUBLIC_HOSTNAME:14374"
