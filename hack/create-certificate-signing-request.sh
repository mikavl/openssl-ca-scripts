#!/usr/bin/env bash
set -e
set -o noglob
set -u

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 common_name [key_bits]"
  exit 1
fi

certificate_common_name="$1"
certificate_key="$certificate_common_name.key"
certificate_key_bits="${2:-2048}"
certificate_signing_request="$certificate_common_name.csr"

umask 0077

if [[ ! -f "$certificate_key" ]]; then
  openssl genrsa -out "$certificate_key" "$certificate_key_bits"
fi

if [[ ! -f "$certificate_signing_request" ]]; then
  openssl req \
    -addext "subjectAltName = DNS:$certificate_common_name" \
    -batch \
    -key "$certificate_key" \
    -new \
    -out "$certificate_signing_request" \
    -sha512 \
    -subj "/CN=$certificate_common_name"
fi
