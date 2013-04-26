cert-scripts
============

Scripts for quick and easy generation of ssl certificates for a development environment

WARNING!!!!
===========
These scripts should only be used in a development environment.  These scripts rely on an untrustworthy CA by default as the private key is fully visible.  They also intentionally cleanup any history which makes it impossible to revoke certificates or track history.

Getting Started
===========

The first step is to distribute a trusted CA to the devlepment team.  A default CA certificate and CA private key is provided in CA_certs/Dev_CA.crt.  It is possible, however, to generate a new CA by running the following command.

./gen-CA

At this point all developers should be able to install the Dev_CA.crt into their browsers.


Now you can create server and user certificates which will be recognized by all parties as signed from a trusted source.

Creating server certificates
===========

To generate a JKS

./gen-server-cert -J

To generate PEM private and public keys

./gen-server-cert -P

By default the scripts will use 'localhost' as the server CN.  This can be changed using the -s option.  For example:

./gen-server-cert -s devcert.com -J

Use the -h option to get a full usage description

Creating user certificates
===========

When using mutual authentication on an application it is important to be able to generate user certificates.  It is possible to generate a P12 file using the following command:

./gen-user-cert

By default the scripts will use 'user' as the users name.  This can be changed using the -u option.  For example:

./gen-user-cert -u "Security Developer"

Use the -h option to get a full usage description






To use these scripts generate a new Root CA and distribute the generated Dev_CA.crt to the development team to import into their browsers.

Then for any servers that need to be authenticated simply generate a new server cert using the supplied script which will be signed by the Dev_CA.

Optionally if using mutual authentication, you can also generate user certificates that are also signed by the Dev_CA.



Usage
===========

createRootCACert.sh - will create a new CA cert called Dev_CA.crt with associated key file.  Both of these files will be generated in the CA_certs directory.

createServerCerts.sh - will create a signed set of server certificates (keystore and truststore).  To have the truststore verify certs from additional CAs simply include the .crt file in the CA_certs directory before running the script.  By default the server certificates created by the script are created in the stores directory.  Run the script with '-h' for additional options.

createUserCert.sh - will create p12 certificates for a user.  All user certificates will be created in certs directory.  Run the script with '-h' for additional options.
