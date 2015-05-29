#!/bin/bash

DEPLOY_RESPONSE=$(cat /tmp/example_deployment.json)

BILLING_ID=$(echo $DEPLOY_RESPONSE  | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-billing")  | .instances[0].id')
SECURITY_ID=$(echo $DEPLOY_RESPONSE | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-security") | .instances[0].id')
DNS_ID=$(echo $DEPLOY_RESPONSE      | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-dns")      | .instances[0].id')
LAUNCHER_ID=$(echo $DEPLOY_RESPONSE | jq '.root_cluster[] | select(.name == "infrastructure") | .nodes[] | select(.node_template_name == "gestalt-launcher") | .instances[0].id')

echo Security: $SECURITY_ID
echo Billing: $BILLING_ID
echo DNS: $DNS_ID
echo Launcher: $LAUNCHER_ID

echo "GESTALT_NODEID=$SECURITY_ID" >> /tmp/security.env
echo "GESTALT_NODEID=$BILLING_ID"  >> /tmp/billing.env
echo "GESTALT_NODEID=$DNS_ID"      >> /tmp/dns.env
echo "GESTALT_NODEID=$LAUNCHER_ID" >> /tmp/launcher.env

