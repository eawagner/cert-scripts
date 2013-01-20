These scripts are for easy creation of self signed development certificates.

createRootCACert.sh - will create a new CA cert called Dev_CA.crt with associated key file.  Both of these files will be generated in the CA_certs directory.

createServerCerts.sh - will create a signed set of server certificates (keystore and truststore).  To have the truststore verify certs from additional CAs simply include the .crt file in the CA_certs directory before running the script.  By default the server certificates created by the script are created in the stores directory.  Run the script with '--help' for additional options.

createUserCert.sh - will create p12 certificates for a user.  All user certificates will be created in certs directory.  Run the script with '--help' for additional options.