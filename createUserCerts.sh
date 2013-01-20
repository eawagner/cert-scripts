#!/bin/bash

source $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/common-funcs.sh

createMultiple() {
    if test -z $N; then
        N=5
    fi
    while test $N -gt 0; do
	FULLNAME="Test User ${N}"
	CERTUSER=testuser${N}
        CERTEMAIL=testuser${N}@devcert.com
	echo $CERTUSER $CERTEMAIL
        createSingle
        N=$((N - 1))
    done

}

escapeName() {
	RES=$(echo "$1" | sed -e 's/[ ]//g')
	RES=$(echo "$RES" | sed -e 's/[.]/_/g')
	RES=$(echo "$RES" | tr "[:upper:]" "[:lower:]")
	echo "$RES"
}

createSingle() {

    CERTUSER=$(escapeName "$CERTUSER")
    
    # set username, email in conf file
    setConfValue emailAddress "$CERTEMAIL" ${CONF_FILE}
    setConfValue CN           "$FULLNAME"  ${CONF_FILE}
    #cat ${CONF_FILE}

    #From CA.pl
    #Generate request file and private key
    openssl req -config ${CONF_FILE} -new -keyout ${KEY_DIR}/${CERTUSER}.key -out ${REQ_DIR}/${CERTUSER}.req -days 3650 -passout "pass:${DEFAULT_PASS}"

    #Sign request and generate certificate
    openssl ca -config ${CONF_FILE} -policy policy_anything -passin "pass:${DEFAULT_PASS}" -batch -out ${TMP_DIR}/${CERTUSER}.crt -infiles ${REQ_DIR}/${CERTUSER}.req

    #convert certificate to pksc12
    openssl pkcs12 -in ${TMP_DIR}/${CERTUSER}.crt -inkey ${KEY_DIR}/${CERTUSER}.key -certfile ${CA_DIR}/${CA_NAME}.crt -out ${CERT_DIR}/${CERTUSER}.p12 -export -name "${FULLNAME}" -passin "pass:${DEFAULT_PASS}" -password "pass:"

    #clean up crt file
    if [ -f ${CERT_DIR}/${CERTUSER}.crt ]; then
        rm -f ${CERT_DIR}/${CERTUSER}.crt
    fi

    echo "Created P12 Certfile: ${CERT_DIR}/${CERTUSER}.p12 ..."
}

usage() {
        echo
        echo " Usage: "
        echo
        echo " For a single user cert: $(basename $0) -u user -e email"
        echo " For Test certs:      $(basename $0) -T [-n <num>]"
        echo
        echo "   Options:"
        echo "      -u  <user>  Use the specified username"
        echo "      -e  <email> Use the specified user e-mail"
        echo "      -n  <num>   Create num certs"
        echo "      -T          Create Test user certs"
        echo
        exit 0
}
# Process Args

# Default action is to create a single cert
ACTION=createSingle

while getopts "u:e:hTn:" flag; do
    case $flag in
        u)
            CERTUSER=$OPTARG
            echo "Using cert user: $CERTUSER"
            ;;
        e)
            CERTEMAIL=$OPTARG
            echo "Using cert e-mail: $CERTEMAIL ..."
            ;;
        n)
            N=$OPTARG
            echo "Setting num user certs to: $OPTARG ..."
            ;;
        T)
            ACTION=createMultiple
            ;;
        h)
            usage
            ;;
    esac
done
    
if test ! -f ${CA_DIR}/${CA_NAME}.crt; then
        echo "$CA_NAME Root Cert Not Found!  Please run 'createRootCACert.sh' ..."
        exit 1
fi



### Main ###

sslInit

case $ACTION in
    createSingle)
        if test -z "$CERTUSER" -o -z "$CERTEMAIL"; then
            usage
        fi
	FULLNAME="$CERTUSER"
        createSingle
        ;;
    createMultiple)
        createMultiple
        ;;
esac

sslClean





