#!/bin/bash 

docker build -t galacticfog.artifactoryonline.com/play-with-ssl-utils:latest . && \
    docker push galacticfog.artifactoryonline.com/play-with-ssl-utils:latest .
