#!/bin/bash 

docker build -t galacticfog.artifactoryonline.com/ifConfigTask:latest . && \
  docker push galacticfog.artifactoryonline.com/ifConfigTask:latest .
