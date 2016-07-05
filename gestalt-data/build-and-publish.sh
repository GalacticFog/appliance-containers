#!/bin/bash 

set -o e

docker build -t galacticfog.artifactoryonline.com/gestalt-data:latest .
docker push galacticfog.artifactoryonline.com/gestalt-data:latest
