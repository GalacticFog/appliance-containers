#!/bin/bash 

set -e

docker build -t galacticfog.artifactoryonline.com/gestalt-data:latest .
docker push galacticfog.artifactoryonline.com/gestalt-data:latest
