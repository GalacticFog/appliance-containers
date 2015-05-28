#!/bin/bash

PUBLIC_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
echo "> PUBLIC_HOSTNAME=$PUBLIC_HOSTNAME"

for f in "docker-compose" "meta"; do 
  echo "> Updating PUBLIC_HOSTNAME in $f"
  sed "s/PUBLIC_HOSTNAME/$PUBLIC_HOSTNAME/g" $f.template.yaml > $f.yaml
done

# deploy appliance blueprint

sudo docker-compose up -d db zookeeper kafka
# restore DB
sudo docker-compose up -d meta
# deploy blueprint in meta, parse topology, set config
#sudo docker-compose -f compose-stage3.yaml up -d

echo "> Meta: http://$PUBLIC_HOSTNAME:14374"
