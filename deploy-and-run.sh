#!/bin/bash

PUBLIC_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
echo "> PUBLIC_HOSTNAME=$PUBLIC_HOSTNAME"

for f in "compose-stage1" "compose-stage2" "compose-stage3" "meta"; do 
  echo "> Updating PUBLIC_HOSTNAME in $f"
  sed "s/PUBLIC_HOSTNAME/$PUBLIC_HOSTNAME/g" $f.template.yaml > $f.yaml
done

# deploy appliance blueprint

sudo docker-compose -f compose-stage1.yaml up -d
#sudo docker-compose -f compose-stage2.yaml up -d
#sudo docker-compose -f compose-stage3.yaml up -d
