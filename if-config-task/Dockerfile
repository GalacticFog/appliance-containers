#
# Utility container for doing curl, jq and postgres client work
#
FROM gliderlabs/alpine:3.1
MAINTAINER chris@galacticfog.com

RUN apk --update add curl jq bash sed

# for testing
COPY example_deployment.json /tmp/example_deployment.json 

COPY deploy-blueprint-set-config.sh /

ENTRYPOINT ["/deploy-blueprint-set-config.sh"]
