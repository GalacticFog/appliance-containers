#!/bin/bash

set -e 

docker build --no-cache -t galacticfog/docker-sbt:1.12 -f Dockerfile.sbt .
docker push     galacticfog/docker-sbt:1.12

docker build --no-cache -t galacticfog/docker-node:1.12 -f Dockerfile.node .
docker push     galacticfog/docker-node:1.12

docker build --no-cache -t galacticfog/gitlab-updater:latest -f Dockerfile.updater .
docker push     galacticfog/gitlab-updater:latest
