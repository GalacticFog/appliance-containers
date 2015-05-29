#!/bin/bash

DEPLOY_RESPONSE=$(cat /tmp/example_deployment.json)

SECURITY_ID=$(echo $DEPLOY_RESPONSE | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-security") | .instances[0].id')
SECURITY_SERVICE_ID=$(echo $DEPLOY_RESPONSE | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-security") | .instances[0].service_id')
BILLING_ID=$(echo $DEPLOY_RESPONSE  | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-billing")  | .instances[0].id')
BILLING_SERVICE_ID=$(echo $DEPLOY_RESPONSE  | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-billing")  | .instances[0].service_id')
DNS_ID=$(echo $DEPLOY_RESPONSE      | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-dns")      | .instances[0].id')
DNS_SERVICE_ID=$(echo $DEPLOY_RESPONSE      | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-dns")      | .instances[0].service_id')
LAUNCHER_ID=$(echo $DEPLOY_RESPONSE | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-launcher") | .instances[0].id')
LAUNCHER_SERVICE_ID=$(echo $DEPLOY_RESPONSE | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-launcher") | .instances[0].service_id')

echo Security: $SECURITY_ID (service $SECURITY_SERVICE_ID)
echo Billing: $BILLING_ID (service $BILLING_SERVICE_ID)
echo DNS: $DNS_ID (service $DNS_SERVICE_ID)
echo Launcher: $LAUNCHER_ID (service $LAUNCHER_SERVICE_ID)

echo "GESTALT_NODE=$SECURITY_ID"            >> /tmp/security.env
echo "GESTALT_SERVICE=$SECURITY_SERVICE_ID" >> /tmp/security.env
echo "GESTALT_NODE=$BILLING_ID"             >> /tmp/billing.env
echo "GESTALT_SERVICE=$BILLING_SERVICE_ID"  >> /tmp/billing.env
echo "GESTALT_NODE=$DNS_ID"                 >> /tmp/dns.env
echo "GESTALT_SERVICE=$DNS_SERVICE_ID"      >> /tmp/dns.env
echo "GESTALT_NODE=$LAUNCHER_ID"            >> /tmp/launcher.env
echo "GESTALT_SERVICE=$LAUNCHER_SERVICE_ID" >> /tmp/launcher.env
