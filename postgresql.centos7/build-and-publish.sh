#!/bin/bash 

docker build -t galacticfog.artifactoryonline.com/centos7postgresql938:latest . && \
    docker push galacticfog.artifactoryonline.com/centos7postgresql938:latest .
