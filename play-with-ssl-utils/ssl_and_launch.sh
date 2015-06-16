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
	echo " * SSLMATE_APIKEY  	- api key for sslmate account"
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


sslmate_config()
{
    echo api_key $1 > $SSLMATE_CONFIG
	check_file        $SSLMATE_CONFIG
}

sslmate_download_cert()
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

openssl_gen_certs()
{
	local domain_name=$1
	local app_name=$2
	local password=$3

	echo "Generating pkcs12 certs for $app_name ..."

	check_availability openssl

	openssl pkcs12 -export -in $domain_name.crt -inkey $domain_name.key -out $domain_name.p12 -name $app_name -CAfile $domain_name.chained.crt -caname root -passin pass:$password -passout pass:$password

	check_file $domain_name.p12
}

gen_keystore()
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
    if [ -z "${SSLMATE_APIKEY+x}" ]; then
      usage "Environment variable SSLMATE_APIKEY not set"
      return 
    fi 
    if [ -z "${DOMAIN_NAME+x}" ]; then 
      usage "Environment variable DOMAIN_NAME not set"
      return 
    fi 

	echo "Creating keystore for app with FQDN $DOMAIN_NAME ..."

	sslmate_config $SSLMATE_APIKEY

	sslmate_download_cert $DOMAIN_NAME

	openssl_gen_certs $DOMAIN_NAME gestaltapp secret

	gen_keystore $DOMAIN_NAME gestaltapp secret
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
