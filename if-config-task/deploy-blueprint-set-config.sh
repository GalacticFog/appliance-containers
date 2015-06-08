#!/usr/bin/env bash
#set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

ORG_ID=1
LOC_ID=1
CLUSTER_NAME="infrastructure-1.0"
BP_NAME="gestalt-infrastructure"

USERS=$(curl -s http://meta:9000/users)
USER_ID=$(echo $USERS | jq -r '.[] | select(.email == "chris@galacticfog.com") | .id')
echo User ID: $USER_ID

read -r -d '' WORKSPACE_CONFIG <<EOM
{
  "org_id": $ORG_ID,
  "owner_id": $USER_ID,
  "name": "Infrastructure",
  "description": "Workspace for infrastructure"
}
EOM
TMP=$(echo $WORKSPACE_CONFIG | curl -s -X POST -d@- -H "Content-Type:application/json" http://meta:9000/workspaces)
sleep 2
WRK_ID=$(curl -s http://meta:9000/workspaces | jq -r '.[] | select(.name == "Infrastructure") | .id')
if [[ -z $WRK_ID ]]; then 
  echo Could not find workspace
  exit 1
fi
echo Workspace ID: $WRK_ID

read -r -d '' ENV_CONFIG <<EOM
{
  "org_id" : $ORG_ID,
  "owner_id" : $USER_ID,
  "env_type" : "dev",
  "name" : "DevInfrastructure",
  "description" : "Dev environment to deploy infrastructure"
}
EOM
TMP=$(echo $ENV_CONFIG | curl -s -X POST -d@- -H "Content-Type:application/json" http://meta:9000/workspaces/$WRK_ID/environments)
sleep 2
ENV_ID=$(curl -s http://meta:9000/workspaces/$WRK_ID/environments | jq -r '.[] | select(.name == "DevInfrastructure") | .id')
if [[ -z $ENV_ID ]]; then 
  echo Could not find environment
  exit 1
fi
echo Environment ID: $ENV_ID

BLUEPRINTS_RESPONSE=$(curl -s http://meta:9000/blueprints)
BLUEPRINT_ID=$(echo $BLUEPRINTS_RESPONSE | jq -r ".[] | select(.name == \"$BP_NAME\") | .id")
if [[ -z $BLUEPRINT_ID ]]; then 
  echo Could not find blueprint
  exit 1
fi
echo "Infrastructure blueprint ID: $BLUEPRINT_ID"

PAYLOAD="{\"location_id\": $LOC_ID, \"environment_id\": $ENV_ID}"
DEPLOY_RESPONSE=$(echo $PAYLOAD | curl -s -d@- -X POST -H "Content-Type:application/json" http://meta:9000/blueprints/$BLUEPRINT_ID/deploy)
#echo -e "Deployment response: \n$DEPLOY_RESPONSE"
DEP_ID=$(echo $DEPLOY_RESPONSE | jq -r '.id')
echo "Deployment ID: $DEP_ID"

CLUSTER_JSON=$(echo $DEPLOY_RESPONSE | jq -r ".root_cluster[] | select(.name == \"$CLUSTER_NAME\")")
if [[ -z $CLUSTER_JSON ]]; then 
  echo Could not find infrastructure cluster \"$CLUSTER_NAME\" among: `echo $DEPLOY_RESPONSE | jq -r '.root_cluster[] | .name'`
  echo -e "Deployment response was: \n\n$DEPLOY_RESPONSE\n\n"
  exit 1
fi
echo Found infrastructure cluster with ID: `echo $CLUSTER_JSON | jq -r '.id'`

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

SEC_NODE=$(getNodeTemplate      "gestalt-security")
BILLING_NODE=$(getNodeTemplate  "gestalt-billing")
DNS_NODE=$(getNodeTemplate      "gestalt-dns")
LAUNCHER_NODE=$(getNodeTemplate "gestalt-launcher")
check "$SEC_NODE"      "gestalt-security"
check "$BILLING_NODE"  "gestalt-billing"
check "$DNS_NODE"      "gestalt-dns"
check "$LAUNCHER_NODE" "gestalt-launcher"

#echo Security: $SEC_NODE
#echo Billing: $BILLING_NODE
#echo DNS: $DNS_NODE
#echo Launcher: $LAUNCHER_NODE

SECURITY_ID=$(getId "$SEC_NODE")
SECURITY_SERVICE_ID=$(getServiceId "$SEC_NODE")
BILLING_ID=$(getId "$BILLING_NODE")
BILLING_SERVICE_ID=$(getServiceId "$BILLING_NODE")
DNS_ID=$(getId "$DNS_NODE")
DNS_SERVICE_ID=$(getServiceId "$DNS_NODE")
LAUNCHER_ID=$(getId "$LAUNCHER_NODE")
LAUNCHER_SERVICE_ID=$(getServiceId "$LAUNCHER_NODE")

echo "Security: $SECURITY_ID (service $SECURITY_SERVICE_ID)"
echo "Billing:  $BILLING_ID (service $BILLING_SERVICE_ID)"
echo "DNS:      $DNS_ID (service $DNS_SERVICE_ID)"
echo "Launcher: $LAUNCHER_ID (service $LAUNCHER_SERVICE_ID)"

echo "GESTALT_NODE=$SECURITY_ID"            >> /tmp/security.env
echo "GESTALT_SERVICE=$SECURITY_SERVICE_ID" >> /tmp/security.env
echo "GESTALT_NODE=$BILLING_ID"             >> /tmp/billing.env
echo "GESTALT_SERVICE=$BILLING_SERVICE_ID"  >> /tmp/billing.env
echo "GESTALT_NODE=$DNS_ID"                 >> /tmp/dns.env
echo "GESTALT_SERVICE=$DNS_SERVICE_ID"      >> /tmp/dns.env
echo "GESTALT_NODE=$LAUNCHER_ID"            >> /tmp/launcher.env
echo "GESTALT_SERVICE=$LAUNCHER_SERVICE_ID" >> /tmp/launcher.env

read -r -d '' DB_CONFIG <<EOM
{
[
  {"op": "add", "path": "/host", "value": "db"},
  {"op": "add", "path": "/port", "value": "5432"},
  {"op": "add", "path": "/db_name", "value": "???"},
  {"op": "add", "path": "/username", "value": "gestsaltdev"},
  {"op": "add", "path": "/password", "value": "M8keitw0rk"}
]
}
EOM
#echo $DB_CONFIG | curl -X PATCH http://meta:9000/environments/$ENV_ID/config

