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

To generate a JKS (Default pass is "changeit")

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
