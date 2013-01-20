CERT_ROOT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
CONF_DIR=${CERT_ROOT_DIR}/conf
CONF_FILE=${CONF_DIR}/openssl.cnf
CERT_DIR=${CERT_ROOT_DIR}/certs
STORE_DIR=${CERT_ROOT_DIR}/stores
CA_DIR=${CERT_ROOT_DIR}/CA_certs
CA_NAME=Dev_CA
TMP_DIR=${CERT_ROOT_DIR}/tmp
KEY_DIR=${TMP_DIR}/keys
REQ_DIR=${TMP_DIR}/reqs
DEFAULT_PASS=pass #must be longer than 4 character, but 

sslInit() {
 
    if test ! -d $CONF_DIR; then
        mkdir -p $CONF_DIR &>/dev/null
    fi

    if test ! -d $CERT_DIR; then
        mkdir -p $CERT_DIR &>/dev/null
    fi

    if test ! -d $CA_DIR; then
        mkdir -p $CA_DIR &>/dev/null
    fi

    if test ! -d $STORE_DIR; then
        mkdir -p $STORE_DIR &>/dev/null
    fi

    if test ! -d $TMP_DIR; then
        mkdir -p $TMP_DIR &>/dev/null

        if test ! -d $KEY_DIR; then
            mkdir -p $KEY_DIR &>/dev/null
        fi

        if test ! -d $REQ_DIR; then
            mkdir -p $REQ_DIR &>/dev/null
        fi

        if test ! -d ${TMP_DIR}/newcerts; then
            mkdir -p ${TMP_DIR}/newcerts &>/dev/null
        fi

        if test ! -f ${TMP_DIR}/index.txt; then
        touch ${TMP_DIR}/index.txt
        fi
    fi

    #Generate a random 20 character hex string for a serial, to be used for signing
    echo $( printf "%04X%04X%04X%04X%04X" ${RANDOM} ${RANDOM} ${RANDOM} ${RANDOM} ${RANDOM} ) > ${CA_DIR}/${CA_NAME}.srl

    setConfValue ca_certs_dir ${CA_DIR} ${CONF_FILE}
    setConfValue dir ${TMP_DIR} ${CONF_FILE}

}

sslClean() {

if test -d $TMP_DIR; then
    rm -rf $TMP_DIR
    rm -rf $REQ_DIR
    rm -rf $KEY_DIR
fi

}

setConfValue() {
    fld_name=$1
    fld_val=$2
    conf_file=$3

    if test ! -f "$conf_file"; then
        echo "Invalid File specified in setConfValue(): $conf_file "
        return 3
    fi

    sed -i -e "s#^$fld_name\([ ]*[=]\)[ ]*.*#$fld_name\1 $fld_val#" $conf_file

}
