#!/bin/bash

PUBLIC_HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/public-hostname)

for f in "compose-stage1" "compose-stage2" "compose-stage3" "meta"; do 
  echo "> Updating PUBLIC_HOSTNAME in $f"
  sed "s/PUBLIC_HOSTNAME/$PUBLIC_HOSTNAME/g" $f.template.yml > $f.yml
done

# deploy appliance blueprint

docker-compose up -d -f compose-stage1.yaml
#docker-compose up -d -f compose-stage2.yaml
#docker-compose up -d -f compose-stage3.yaml
