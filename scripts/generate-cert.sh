#!/usr/bin/env sh
set -eu
mkdir -p nginx/certs
openssl req -x509 -nodes -days 365 -newkey rsa:3072 \
  -keyout nginx/certs/localhost.key \
  -out nginx/certs/localhost.crt \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
chmod 600 nginx/certs/localhost.key
chmod 644 nginx/certs/localhost.crt
echo "Created nginx/certs/localhost.crt and localhost.key"
