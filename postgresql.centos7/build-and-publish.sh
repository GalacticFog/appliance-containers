#!/bin/bash 

docker build -t galacticfog.artifactoryonline.com/centos7postgresql944:latest . && \
    docker push galacticfog.artifactoryonline.com/centos7postgresql944:latest .
