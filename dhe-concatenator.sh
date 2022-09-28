#!/bin/bash

## The configuration option << SSLOpenSSLConfCmd DHParameters "/etc/ssl/ffdhe4096.pem" >> is not working anymore in Apache 2.4.52.
## As a result you cannot use a custom DHE public key anymore, like the one that uses predefined finite field groups that are specified in RFC 7919 (necessary for Internet.nl compliance)
## For more information, see: https://bz.apache.org/bugzilla/show_bug.cgi?id=65764

## I made this small script to work around this problem when using Lets Encrypt.
## This script concatenates the original fullchain.pem file with the custom DHE public key /etc/ssl/ffdhe4096.pem.
## Make sure to adjust the configuration in Apache: << SSLCertificateFile /etc/letsencrypt/live/www.baaten.com/fullchain.pem.dh4096 >>
## I tried running this as a Lets Encrypt renewal hook, but for some reason this is not working.
## So for the time being, I run this script every hour (cronjob) for all certificates. This suits my needs, but this might not be suitable for all environments.

## Author: Dennis Baaten (Baaten ICT Security)

for certfile in $(certbot certificates | grep "Certificate Path" | sed -e 's/^[ \t]*//' | cut -f3 -d " ")
do
        cat $certfile /etc/ssl/ffdhe4096.pem > $certfile.dh4096
done
systemctl restart apache2.service
