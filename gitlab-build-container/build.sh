docker build -t galacticfog/docker-sbt:1.7 .
docker push galacticfog/docker-sbt:1.7

docker build -t galacticfog/docker-node:1.7 -f Dockerfile.node .
docker push galacticfog/docker-node:1.7
