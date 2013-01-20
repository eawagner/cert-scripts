#!/bin/bash

source $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/common-funcs.sh

# set some sane defaults
SERVER_NAME=localhost
DEFAULT_ALIAS=devcert
KEYPASS=winter
STOREPASS=winter
KEYSTORE=${STORE_DIR}/development.keystore
TRUSTSTORE=${STORE_DIR}/development.truststore

createStores() {
    #Create keystore
    if [ -f ${KEYSTORE} ]; then
        echo "Removing old keystore: ${KEYSTORE} ..."
        rm ${KEYSTORE} 
    fi
    
    ALIAS=tomcat

    echo "Generating new Tomcat keystore ..."
    keytool -genkeypair -validity 3650 -alias ${DEFAULT_ALIAS} -keysize 2048 -keyalg RSA -dname "${SERVER_DN}" \
     -keypass ${KEYPASS} -keystore ${KEYSTORE} \
     -storepass ${STOREPASS} 

    #Create truststore
    if [ -f ${TRUSTSTORE} ]; then
        echo "Removing old truststrore: ${TRUSTSTORE} ..."
        rm ${TRUSTSTORE}
    fi

    echo "Generating new Tomcat trustore ..."
    # import keystore --> truststore
    keytool -genkeypair -validity 3650 -alias ${DEFAULT_ALIAS} -keysize 2048 -keyalg RSA -dname "${SERVER_DN}" \
     -keypass ${KEYPASS} -keystore ${TRUSTSTORE} \
     -storepass ${STOREPASS} 
    
}


# Import Dev CA into keystore
importCAs() {
	
    for file in ${CA_DIR}/*.crt; do
	echo "Importing CA cert: $file ..."
	ALIAS=$(basename "$file")
	ALIAS=${ALIAS%%.*}
        keytool -import -v -trustcacerts -alias ${ALIAS} -keystore \
        ${TRUSTSTORE} -file "${file}" -noprompt -storepass ${STOREPASS} 
    done 

    #must import our ca to establish the chain for the keystore when signing
    keytool -import -v -trustcacerts -alias ${CA_NAME} -keystore ${KEYSTORE} -file ${CA_DIR}/${CA_NAME}.crt -noprompt -storepass ${STOREPASS} 
   
}

# list stored keys
listKeys() {
    echo "#################################################################"
    echo "## TRUSTSTORE"
    keytool -list -v -keystore ${TRUSTSTORE} -storepass ${STOREPASS}
    echo
    echo "#################################################################"
    echo "## KEYSTORE"
    keytool -list -v -keystore ${KEYSTORE} -storepass ${STOREPASS}

}

signStores() {

    #Gen request for signing
    keytool -certreq -v -alias ${DEFAULT_ALIAS} -keystore ${KEYSTORE} -storepass ${STOREPASS} -file ${REQ_DIR}/${SERVER_NAME}.req

    #Sign with our ca
    openssl ca -config ${CONF_FILE} -policy policy_anything -passin "pass:${DEFAULT_PASS}" -batch -out ${TMP_DIR}/${SERVER_NAME}.crt -infiles ${REQ_DIR}/${SERVER_NAME}.req

    #convert to der format
    openssl x509 -in ${TMP_DIR}/${SERVER_NAME}.crt -out ${TMP_DIR}/${SERVER_NAME}.crt -outform DER

    #import the signed cert back into keystore
    keytool -importcert -v -alias ${DEFAULT_ALIAS} -keystore ${KEYSTORE} -storepass ${STOREPASS} -keypass ${KEYPASS} -file ${TMP_DIR}/${SERVER_NAME}.crt -noprompt

}

usage() {
    echo "usage: $0 [option]"
    echo
    echo "   Options:"
    echo "      -s  <name>      Use the specified [s]ervername"
    echo "      -k  <passwd>    Use the specified [k]ey password"
    echo "      -t  <passwd>    Use the specified s[t]ore password"
    echo "      -T <filename>   Truststore file (will be created)"
    echo "      -K <filename>   Keystore file (will be created)"
    echo
    exit 0
}

# process arguments overriding defaults as needed
while getopts "s:t:k:hK:T:" flag; do
        case $flag in
                s)
                    SERVER_NAME=$OPTARG
                    echo "Using servername: $SERVER_NAME"
                    ;;
                k)
                    KEYPASS=$OPTARG
                    echo "Using keypass: $KEYPASS ..."
                    ;;
                t)
                    STOREPASS=$OPTARG
                    echo "Using storePass: $STOREPASS ..."
                    ;;

                K)
                    KEYSTORE=$OPTARG
                    echo "Using keystore file: $KEYSTORE ..."
                    ;;
                T)
                    TRUSTSTORE=$OPTARG
                    echo "Using truststore file: $TRUSTSTORE ..."
                    ;;
                h)
                    usage
                    ;;
       esac
done

SERVER_DN="CN=${SERVER_NAME},OU=Test,O=Development,L=columbia,S=MD,C=US"

### MAIN ###

sslInit
createStores
importCAs
signStores
listKeys
sslClean

