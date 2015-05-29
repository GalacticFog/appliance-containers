#!/bin/bash 

docker build -t galacticfog.artifactoryonline.com/if-config-task:latest . && \
  docker push galacticfog.artifactoryonline.com/if-config-task:latest .
