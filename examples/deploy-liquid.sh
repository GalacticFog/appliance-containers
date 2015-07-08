#!/bin/bash 

ORG_ID=1
LOC_ID=1
CLUSTER_NAME="liquid-root-1.0"
BP_NAME="liquid-app-1.0"
ENV_ID=19
HOST=localhost

BLUEPRINTS_RESPONSE=$(curl -s http://$HOST:14374/blueprints)
BLUEPRINT_ID=$(echo $BLUEPRINTS_RESPONSE | jq -r ".[] | select(.name == \"$BP_NAME\") | .id")
if [[ -z $BLUEPRINT_ID ]]; then 
  echo Could not find blueprint
  exit 1
fi
echo "Using liquid blueprint ID: $BLUEPRINT_ID"

PAYLOAD="{\"location_id\": $LOC_ID, \"environment_id\": $ENV_ID}"
DEPLOY_RESPONSE=$(echo $PAYLOAD | curl -s -d@- -X POST -H "Content-Type:application/json" http://$HOST:14374/blueprints/$BLUEPRINT_ID/deploy)
#echo -e "Deployment response: \n$DEPLOY_RESPONSE"
DEP_ID=$(echo $DEPLOY_RESPONSE | jq -r '.id')
echo "Deployment ID: $DEP_ID"

CLUSTER_JSON=$(echo $DEPLOY_RESPONSE | jq -r ".root_cluster[] | select(.name == \"$CLUSTER_NAME\" )")

getId() {
  echo "$1" | jq -r '.instances[0].id'
}
getServiceId() {
  echo "$1" | jq -r '.instances[0].service_id'
}
getNodeTemplate() {
  echo "$CLUSTER_JSON" | jq -r ".nodes[] | select(.node_template_name == \"$1\")"
}
check() {
  if [[ -z $1 ]]; then 
    echo Could not find node template "$2" among: `echo "$CLUSTER_JSON" | jq -r '.nodes[] | .node_template_name'`
    exit 1
  fi
}

NOT_NODE=$(getNodeTemplate  "notifier")
LIQ_NODE=$(getNodeTemplate  "liquid-1.0")
check "$NOT_NODE"  "notifier"
check "$LIQ_NODE"  "liquid-1.0"
NOT_ID=$(getId "$NOT_NODE")
LIQ_ID=$(getId "$LIQ_NODE")

echo Notifier is node: $NOT_ID
echo Liquid is node: $LIQ_ID

P=$(curl -f -s -X PATCH -d '[ 
  { "op" : "add", "path" : "/protocol", "value" : "http" },
  { "op" : "add", "path" : "/hostname", "value" : "security" },
  { "op" : "add", "path" : "/port",     "value" : "9000" },
  { "op" : "add", "path" : "/appId",    "value" : "TF1HJxn9uMtURqxNSgY76aH4" }
]' -H 'Content-Type:application/json' $HOST:14374/nodes/$NOT_ID/configs/authentication)

# echo Auth Response config : $P

Q=$(curl -f -s -X PATCH -d '[ 
	{ "op" : "add", "path" : "/hosts", "value" : "[{\"host\": \"kafka\", \"port\": 9092}]"}, 
	{ "op" : "add", "path" : "/channel", "value" : "test/group.1" } 
]' -H 'Content-Type:application/json' $HOST:14374/nodes/$LIQ_ID/configs/stream-logger)

# echo Stream Logger Response config : $P

R=$(curl -f -s -X PATCH -d '[ 
	{ "op" : "add", "path" : "/host", "value" : "zookeeper"}, 
	{ "op" : "add", "path" : "/port", "value" : "2181" }, 
	{ "op" : "add", "path" : "/channel", "value" : "test/group.1" },
	{ "op" : "add", "path" : "/read_from_beginning", "value" : false } 
]' -H 'Content-Type:application/json' $HOST:14374/nodes/$LIQ_ID/configs/stream-listener)

# echo Stream Listener Response config : $P

cat > notifier.env <<EOM
GESTALT_META=http://meta:9000
GESTALT_ORG=com.galacticfog
GESTALT_ID=gestalt-notifier
GESTALT_VERSION=1.1-SNAPSHOT
GESTALT_NODE_ID=$NOT_ID
GESTALT_ENV="Liquid-DEV;dev"
GESTALT_SECRET=9f57a371065545e993684e2c53070b1f
EOM

cat > liquid.env <<EOM
GESTALT_META=http://meta:9000
GESTALT_ORG=com.galacticfog
GESTALT_ID=liquid
GESTALT_VERSION=1.0
GESTALT_NODE_ID=$LIQ_ID
GESTALT_ENV="Liquid-DEV;dev"
GESTALT_SECRET=9f57a371065545e993684e2c53070b1f
EOM

docker run -d --env-file=notifier.env \
	--link=meta:meta \
	--link=security:security \
	--link=kafka:kafka \
	--link=zookeeper:zookeeper \
	--publish=5309:9000 \
	--name=notifier galacticfog.artifactoryonline.com/gestalt-notifier:latest

docker run -d --env-file=liquid.env \
	--link=meta:meta \
	--link=security:security \
	--link=kafka:kafka \
	--link=zookeeper:zookeeper \
	--publish=9002:9000 \
	--name=liquid galacticfog.artifactoryonline.com/liquid:latest 
