#!/usr/bin/env bash
set -e
set -o noglob
set -u

. "$(dirname "$(realpath "$0")")/_helpers.sh"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 common_name [key_bits] [days] [certificate_revokation_list_days]"
  exit 1
fi

ca_certificate_days="${3:-365}"
ca_certificate_key_bits="${2:-4096}"
ca_certificate_revokation_list_days="${3:-30}"
ca_common_name="$1"
ca_directory="$ca_common_name"

umask 0077

mkdir -p "$ca_directory"

if [[ ! -f "$ca_directory/$openssl_config" ]]; then
  cp "$openssl_config.example" "$ca_directory/$openssl_config"
fi

cd "$ca_directory"

touch "$ca_database"

if [[ ! -f "$ca_certificate_key_passphrase" ]]; then
  generate_passphrase > "$ca_certificate_key_passphrase"
fi

if [[ ! -f "$ca_certificate_key" ]]; then
  openssl genrsa \
    -aes256 \
    -out "$ca_certificate_key" \
    -passout file:"$ca_certificate_key_passphrase" \
    "$ca_certificate_key_bits"
fi

if [[ ! -f "$ca_certificate" ]]; then
  openssl req \
    -batch \
    -config "$openssl_config" \
    -days "$ca_certificate_days" \
    -extensions v3_ca \
    -key "$ca_certificate_key" \
    -new \
    -out "$ca_certificate" \
    -passin file:"$ca_certificate_key_passphrase" \
    -subj "/CN=$ca_common_name" \
    -x509
fi

if [[ ! -f "$ca_certificate_revokation_list" ]]; then
  openssl ca \
    -batch \
    -config "$openssl_config" \
    -crldays "$ca_certificate_revokation_list_days" \
    -gencrl \
    -out "$ca_certificate_revokation_list" \
    -passin file:"$ca_certificate_key_passphrase"
fi
