#!/usr/bin/env bash

ca_certificate="ca.pem"
ca_certificate_key="ca.key"
ca_certificate_key_passphrase="passphrase"
ca_certificate_revokation_list="crl.pem"
ca_database="index"
certificate_directory="certs"
openssl_config="openssl.cnf"

generate_passphrase()
{
  head -c 8k < /dev/urandom | sha512sum | awk '{print $1}' | tr -d '\n'
}
