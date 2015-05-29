#!/bin/bash 

docker build -t galacticfog.artifactoryonline.com/utilimage:latest . && \
  docker push galacticfog.artifactoryonline.com/utilimage:latest .
