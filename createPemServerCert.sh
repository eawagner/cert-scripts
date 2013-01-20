#!/bin/bash

source $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/common-funcs.sh

# set some sane defaults
SERVER_NAME=localhost
CERT=${STORE_DIR}/development.crt


createCertificate () {
    SERVER_DN="CN=${SERVER_NAME},OU=Test,O=Development,L=columbia,S=MD,C=US"
    setConfValue CN           "$SERVER_NAME"  ${CONF_FILE}
    setConfValue emailAddress "$SERVER_NAME" ${CONF_FILE}
    setConfValue OU           "Test"  ${CONF_FILE}
    setConfValue O            "Development"  ${CONF_FILE}
    setConfValue L            "columbia"  ${CONF_FILE}
    setConfValue ST           "MD"  ${CONF_FILE}
    setConfValue C            "US"  ${CONF_FILE}

    #Generate a new key and request
    openssl req -config ${CONF_FILE} -newkey rsa:2048 -keyout ${KEY_DIR}/${SERVER_NAME}.key -keyform PEM -out ${REQ_DIR}/${SERVER_NAME}.req -outform PEM -passout "pass:${DEFAULT_PASS}" -days 3650

    #Decrypt the key
    openssl rsa -in ${KEY_DIR}/${SERVER_NAME}.key -out ${KEY_DIR}/${SERVER_NAME}.key.decrypted -passin "pass:${DEFAULT_PASS}"

    #Sign the request with the CA
    openssl ca -config ${CONF_FILE} -policy policy_anything -in ${REQ_DIR}/${SERVER_NAME}.req -out ${CERT} -passin "pass:${DEFAULT_PASS}" -batch

    #Combine the key to the end of the certificate so that both cert and key are in same file.
    cat ${KEY_DIR}/${SERVER_NAME}.key.decrypted >> ${CERT}

}

usage() {
    echo "usage: $0 [option]"
    echo
    echo "   Options:"
    echo "      -s  <name>      Use the specified [s]ervername"
    echo "      -C <filename>   Certificate file (will be created)"
    echo
    exit 0
}

# process arguments overriding defaults as needed
while getopts "s:hK:C:" flag; do
        case $flag in
                s)
                    SERVER_NAME=$OPTARG
                    echo "Using servername: $SERVER_NAME"
                    ;;
                C)
                    CERT=$OPTARG
                    echo "Using certificate file: $CERT ..."
                    ;;
                h)
                    usage
                    ;;
       esac
done

### MAIN ###

sslInit

createCertificate

sslClean

