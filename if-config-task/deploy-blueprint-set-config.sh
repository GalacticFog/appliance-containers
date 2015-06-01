#!/bin/bash

ENV_ID=1
LOC_ID=1

BLUEPRINTS_RESPONSE=$(cat /tmp/example_blueprints.json)
#BLUEPRINTS_RESPONSE=$(curl -s meta:9000/blueprints)
BLUEPRINT_ID=$(echo $BLUEPRINTS_RESPONSE | jq -r '.[] | select(.name == "infrastructure") | .id')
echo "Infrastructure blueprint ID: $BLUEPRINT_ID"

PAYLOAD="{\"location_id\": $ENV_ID, \"environment_id\": $LOC_ID}"
#DEPLOY_RESPONSE=$(echo $PAYLOAD | curl -s -d@- -X POST http://meta:9000/blueprints/$BLUEPRINT_ID/deploy)
DEPLOY_RESPONSE=$(cat /tmp/example_deployment.json)

SECURITY_ID=$(echo $DEPLOY_RESPONSE | jq -r '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-security") | .instances[0].id')
SECURITY_SERVICE_ID=$(echo $DEPLOY_RESPONSE | jq -r '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-security") | .instances[0].service_id')
BILLING_ID=$(echo $DEPLOY_RESPONSE  | jq -r '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-billing")  | .instances[0].id')
BILLING_SERVICE_ID=$(echo $DEPLOY_RESPONSE  | jq -r '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-billing")  | .instances[0].service_id')
DNS_ID=$(echo $DEPLOY_RESPONSE      | jq -r '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-dns")      | .instances[0].id')
DNS_SERVICE_ID=$(echo $DEPLOY_RESPONSE      | jq -r '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-dns")      | .instances[0].service_id')
LAUNCHER_ID=$(echo $DEPLOY_RESPONSE | jq -r '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-launcher") | .instances[0].id')
LAUNCHER_SERVICE_ID=$(echo $DEPLOY_RESPONSE | jq -r '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-launcher") | .instances[0].service_id')

echo "Security: $SECURITY_ID (service $SECURITY_SERVICE_ID)"
echo "Billing: $BILLING_ID (service $BILLING_SERVICE_ID)"
echo "DNS: $DNS_ID (service $DNS_SERVICE_ID)"
echo "Launcher: $LAUNCHER_ID (service $LAUNCHER_SERVICE_ID)"

echo "GESTALT_NODE=$SECURITY_ID"            >> /tmp/security.env
echo "GESTALT_SERVICE=$SECURITY_SERVICE_ID" >> /tmp/security.env
echo "GESTALT_NODE=$BILLING_ID"             >> /tmp/billing.env
echo "GESTALT_SERVICE=$BILLING_SERVICE_ID"  >> /tmp/billing.env
echo "GESTALT_NODE=$DNS_ID"                 >> /tmp/dns.env
echo "GESTALT_SERVICE=$DNS_SERVICE_ID"      >> /tmp/dns.env
echo "GESTALT_NODE=$LAUNCHER_ID"            >> /tmp/launcher.env
echo "GESTALT_SERVICE=$LAUNCHER_SERVICE_ID" >> /tmp/launcher.env


read -r -d '' DB_CONFIG <<- EOM
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
