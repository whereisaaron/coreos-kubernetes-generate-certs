#!/bin/bash

#
# Create a set of certificate to meet the kube-aws certificate requirements
# Tested with kube-aws 0.8.1 and OpenSSL 1.0.1f
#

# Org to use in all certs
ORG=kube-aws

# Target folder to copy certs
OUTFOLDER="../credentials/"

# Create configuration api cert -- UPDATE THESE FOR YOUR ENVIRONMENT
export API_DNS_NAME=your.domain.name
export K8S_SERVICE_IP=172.16.0.50
export MASTER_HOST=10.31.0.1
envsubst < apiserver-openssl-template.cnf > apiserver-openssl.cnf

# Generate root key and cert
openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/O=${ORG}/CN=kube-ca" -extensions v3_ca -config ca-openssl.cnf

# Generate api key and cert, sign with root cert, remove temp files
openssl genrsa -out apiserver-key.pem 2048
openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/O=${ORG}/CN=kube-apiserver" -config apiserver-openssl.cnf
openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 3650 -extensions v3_req -extfile apiserver-openssl.cnf
rm apiserver.csr apiserver-openssl.cnf

# Generate worker key and cert, sign with root cert, remove temp files
# A wildcard cert is used to match any AWS instance, rather than per-worker certs
openssl genrsa -out worker-key.pem 2048
openssl req -new -key worker-key.pem -out worker.csr -subj "/O=${ORG}/CN=kube-worker" -config worker-openssl.cnf
openssl x509 -req -in worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out worker.pem -days 1095 -extensions v3_req -extfile worker-openssl.cnf
rm worker.csr

# Generate admin key and cert, sign with root cert, remove temp files
openssl genrsa -out admin-key.pem 2048
openssl req -new -key admin-key.pem -out admin.csr -subj "/O=${ORG}/CN=kube-admin" -config admin-openssl.cnf
openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 1095 -extensions v3_req -extfile admin-openssl.cnf
rm admin.csr

FILES="ca.pem ca-key.pem apiserver.pem apiserver-key.pem worker.pem worker-key.pem admin.pem admin-key.pem"
READY=1
for f in $FILES
do
  if [ ! -f "$f" ]
  then
    echo File $f is missing
    READY=0
  fi
done

if [ "$READY" -eq 1 -a "$OUTFOLDER" -ne "" ]
then
  cp -vn $FILES "$OUTFOLDER"
fi
