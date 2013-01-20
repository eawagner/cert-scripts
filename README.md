cert-scripts
============

Scripts for generating ssl certificates


These scripts are for easy creation of signed development certificates.

To use these scripts generate a new Root CA and distribute the generated Dev_CA.crt to the development team to import into their browsers.

Then for any servers that need to be authenticated simply generate a new server cert using the supplied script which will be signed by the Dev_CA.

Optionally if using mutual authentication, you can also generate user certificates that are also signed by the Dev_CA.

WARNING!!!!
These scripts should only be used in a development environment.  They intentionally cleanup any history which makes it impossible to revoke certificates or track history.

Usage
===========

createRootCACert.sh - will create a new CA cert called Dev_CA.crt with associated key file.  Both of these files will be generated in the CA_certs directory.

createServerCerts.sh - will create a signed set of server certificates (keystore and truststore).  To have the truststore verify certs from additional CAs simply include the .crt file in the CA_certs directory before running the script.  By default the server certificates created by the script are created in the stores directory.  Run the script with '-h' for additional options.

createUserCert.sh - will create p12 certificates for a user.  All user certificates will be created in certs directory.  Run the script with '-h' for additional options.
