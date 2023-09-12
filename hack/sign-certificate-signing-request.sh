#!/usr/bin/env bash
set -e
set -o noglob
set -u

. "$(dirname "$(realpath "$0")")/_helpers.sh"

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 certificate_authority_common_name type common_name [days] [certificate_revokation_list_days]"
  exit 1
fi

certificate_type="$2"

if ! [[ "$certificate_type" =~ ^(client|server|clientserver)$ ]]; then
  echo "Unknown certificate type: $certificate_type"
  exit 1
fi

certificate_common_name="$3"

ca_common_name="$1"
ca_certificate_revokation_list_days="${5:-30}"
ca_directory="$ca_common_name"
certificate="$certificate_directory/$certificate_type-$certificate_common_name.pem"
certificate_days="${4:-30}"
certificate_signing_request="$certificate_directory/$certificate_type-$certificate_common_name.csr"

umask 0077

mkdir -p "$ca_directory/$certificate_directory"

cp -f "$certificate_common_name.csr" "$ca_directory/$certificate_signing_request"

cd "$ca_directory"

chmod 755 "$certificate_directory"

if [[ -f "$certificate" ]]; then
  openssl ca \
    -batch \
    -config "$openssl_config" \
    -passin file:"$ca_certificate_key_passphrase" \
    -revoke "$certificate"

  openssl ca \
    -batch \
    -config "$openssl_config" \
    -crldays "$ca_certificate_revokation_list_days" \
    -gencrl \
    -out "$ca_certificate_revokation_list" \
    -passin file:"$ca_certificate_key_passphrase"

  chmod 644 "$ca_certificate_revokation_list"

  rm -f "$certificate"
fi

openssl ca \
  -batch \
  -config "$openssl_config" \
  -days "$certificate_days" \
  -extensions "${certificate_type}_cert" \
  -in "$certificate_signing_request" \
  -notext \
  -out "$certificate" \
  -passin file:"$ca_certificate_key_passphrase"

chmod 644 "$certificate"
