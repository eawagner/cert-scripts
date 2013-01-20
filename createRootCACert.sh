#!/bin/bash

source $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/common-funcs.sh

sslInit

setConfValue emailAddress "dev_root_ca@devcert.com" ${CONF_FILE}
setConfValue CN           "Dev_Root_CA"  ${CONF_FILE}

#From CA.pl
# gen CA_ROOT key and CA_ROOT request
openssl req -config ${CONF_FILE} -new -keyout ${CA_DIR}/${CA_NAME}.key -out ${REQ_DIR}/${CA_NAME}.req -days 3650 -passout "pass:${DEFAULT_PASS}"

# gen signed CA_ROOT certificate
openssl ca -config ${CONF_FILE} -create_serial -out ${CA_DIR}/${CA_NAME}.crt -days 3650 -batch -keyfile ${CA_DIR}/${CA_NAME}.key -selfsign -passin "pass:${DEFAULT_PASS}" -extensions v3_ca -infiles ${REQ_DIR}/${CA_NAME}.req 

openssl x509 -in ${CA_DIR}/${CA_NAME}.crt -days 3650 -out ${CA_DIR}/${CA_NAME}.crt -passin "pass:${DEFAULT_PASS}" -signkey ${CA_DIR}/${CA_NAME}.key

sslClean


