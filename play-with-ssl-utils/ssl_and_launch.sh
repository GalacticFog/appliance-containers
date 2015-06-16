#!/bin/bash
set -o nounset
set -o errexit
#debug
set -x


usage()
{
	echo "------------------------------------------------------------------------------------------------"
	echo "ERROR : $1 "
	echo ""
	echo "Usage:"
	echo ""
	echo "ssl_and_launch.sh <executable_script>"
	echo ""
	echo " * executable_script 	- script to launch the application"
    echo ""
    echo "Relevant Environment Variables"
    echo " * ENABLE_SSL         - download an SSL certificate and use it to configure the service"
    echo " * DOMAIN_NAME        - domain name for the certificate"
	echo " * SSLMATE_USERNAME	- admin username for your sslmate account"
	echo " * SSLMATE_PASSWORD	- admin password for your sslmate account"
	echo "------------------------------------------------------------------------------------------------"
	exit 1
}

check_availability()
{
	hash $1 2>/dev/null || usage "This script requires $1, but it was not found on this system"
}

check_file()
{
	if [ ! -f $1 ]; then
		usage "File $1 does not exist"
	fi
}


#this is spoofing the undocumented REST API of SSLMate and providing the account info that we need
#to grab our domain info
ssl_link()
{

	check_availability curl
	check_file "/opt/bin/parse.py"

	local api_url="https://sslmate.com/api/v1/link"
	local username=$1
	local password=$2

	RET=$(curl -s -X POST -A "SSLMate/0.6.2" --data "account_username=$username&account_password=$password" $api_url)
	VALS=( `echo $RET | /opt/bin/parse.py account_id api_key `)
	echo account_id ${VALS[0]} > $SSLMATE_CONFIG
	echo api_key ${VALS[1]}   >> $SSLMATE_CONFIG

	check_file $SSLMATE_CONFIG
}

ssl_mate()
{
	echo "Downloading sslmate certificates for $1 ..." 

	check_availability sslmate

	#TODO : validate the input (e.g. blah.something.[com|gov|edu])

	local domain_name=$1

	sslmate download $domain_name

	check_file $domain_name.crt
	check_file $domain_name.chain.crt
	check_file $domain_name.chained.crt

}

open_ssl()
{
	local domain_name=$1
	local app_name=$2
	local password=$3

	echo "Generating pkcs12 certs for $app_name ..."

	check_availability openssl

	openssl pkcs12 -export -in $domain_name.crt -inkey $domain_name.key -out $domain_name.p12 -name $app_name -CAfile $domain_name.chained.crt -caname root -passin pass:$password -passout pass:$password

	check_file $domain_name.p12
}

key_store()
{
	local domain_name=$1
	local app_name=$2
	local password=$3

	echo "Generating keystore for $app_name ..."

	check_availability keytool

	keytool -importkeystore -deststorepass $password -destkeypass $password -destkeystore $app_name.keystore -srckeystore $domain_name.p12 -srcstoretype PKCS12 -srcstorepass $password -alias $app_name

	check_file $app_name.keystore
}

launch_with_ssl()
{
    echo "launching with ssl"
    $1 -Dhttp.port=disabled -Dhttps.port=9000 -Dhttps.keyStore=appcert.keystore -Dhttps.keyStorePassword=secret
}

launch_without_ssl()
{
    echo "launching without ssl"
    $1
}

configure_keystore()
{
    if [ -z "${SSLMATE_USERNAME+x}" ]; then
      usage "Environment variable SSLMATE_USERNAME not set"
      return 
    fi 
    if [ -z "${SSLMATE_PASSWORD+x}" ]; then 
      usage "Environment variable SSLMATE_PASSWORD not set"
      return 
    fi 
    if [ -z "${DOMAIN_NAME+x}" ]; then 
      usage "Environment variable DOMAIN_NAME not set"
      return 
    fi 

	echo "Creating keystore for app with FQDN $DOMAIN_NAME ..."

	ssl_link $SSLMATE_USERNAME $SSLMATE_PASSWORD

	ssl_mate $DOMAIN_NAME

	open_ssl $DOMAIN_NAME gestaltapp secret

	key_store $DOMAIN_NAME gestaltapp secret
}

export SSLMATE_CONFIG=/opt/docker/sslmate.conf

[ "$#" -eq 1 ] || usage "Expected 1 parameter and only $# provided"

if [ -z ${ENABLE_SSL+x} && "${ENABLE_SSL}" -ne 0 ]; then 
  configure_keystore "$@"
  if [ -f appcert.keystore ]; then 
    launch_with_ssl "$@"
  else 
     echo "Error configuring ssl."
     exit 1
  fi
else 
  launch_without_ssl "$@"
fi
