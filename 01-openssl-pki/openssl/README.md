# OpenSSL PKI Reference

-----

<!-- toc -->

**Table of Contents**

- [OpenSSL PKI
  Reference](#openssl-pki-reference)
  - [Installing necessary
    packages](#installing-necessary-packages)
  - [Creating PKI
    directory](#creating-pki-directory)
    - [Create PKI hierarchy
      directories](#create-pki-hierarchy-directories)
    - [Create serial files to keep track of issued and revoked
      certificates](#create-serial-files-to-keep-track-of-issued-and-revoked-certificates)
    - [Create a text file to be used as a database for all
      certificates](#create-a-text-file-to-be-used-as-a-database-for-all-certificates)
    - [Create an OpenSSL configuration to store all config and database
      related
      data](#create-an-openssl-configuration-to-store-all-config-and-database-related-data)
    - [Render the OpenSSL
      configuration](#render-the-openssl-configuration)
  - [Issuing
    Certificates](#issuing-certificates)
    - [Root-CA](#root-ca)
      - [Generate a private key for CA using one the
        commands](#generate-a-private-key-for-ca-using-one-the-commands)
      - [Secure the private
        key](#secure-the-private-key)
      - [Generate CA
        certificate](#generate-ca-certificate)
    - [Intermediate-CAs](#intermediate-cas)
      - [Generate private keys for
        Inter-CA](#generate-private-keys-for-inter-ca)
      - [Secure the private
        keys](#secure-the-private-keys)
      - [Generate a Certificate Request
        (CSR)](#generate-a-certificate-request-csr)
      - [Sign the CSR](#sign-the-csr)
    - [Non-CA
      certificates](#non-ca-certificates)
      - [OCSP Certificate](#ocsp-certificate)
        - [Generate a private key for
          OCSP](#generate-a-private-key-for-ocsp)
        - [Secure the private
          key](#secure-the-private-key-1)
        - [Generate a Certificate Request
          (CSR)](#generate-a-certificate-request-csr-1)
        - [Sign the CSR](#sign-the-csr-1)
      - [Server
        Certificate](#server-certificate)
        - [Specify a domain](#specify-a-domain)
        - [Generate a private key for
          Non-CA](#generate-a-private-key-for-non-ca)
        - [Secure the private
          key](#secure-the-private-key-2)
        - [Generate a Certificate Request
          (CSR)](#generate-a-certificate-request-csr-2)
        - [Sign the CSR](#sign-the-csr-2)
      - [Client
        Certificate](#client-certificate)
        - [Specify a user
          identifier](#specify-a-user-identifier)
        - [Generate a private key for
          Non-CA](#generate-a-private-key-for-non-ca-1)
        - [Secure the private
          key](#secure-the-private-key-3)
        - [Generate a Certificate Request
          (CSR)](#generate-a-certificate-request-csr-3)
        - [Sign the CSR](#sign-the-csr-3)
  - [Certificate
    Revoking](#certificate-revoking)
    - [Revoke a
      Certificate](#revoke-a-certificate)
    - [Generate Certificate Revoke List
      (CRL)](#generate-certificate-revoke-list-crl)
    - [View a CRL](#view-a-crl)
  - [OCSP Server](#ocsp-server)
    - [Run an OCSP server using
      OpenSSL](#run-an-ocsp-server-using-openssl)
    - [Test a certificate against an OCSP
      server](#test-a-certificate-against-an-ocsp-server)
  - [Extra commands](#extra-commands)
    - [Preview an X509
      certificate](#preview-an-x509-certificate)
    - [Combine certificates into a
      chain](#combine-certificates-into-a-chain)
    - [Generate a PKCS12](#generate-a-pkcs12)
    - [Generate a list of Intermediate-CAs](#generate-a-list-of-intermediate-cas)

<!-- tocstop -->
-----

### Installing necessary packages

- openssl

``` sh
# Debian Trixie
sudo apt update
sudo apt install -y openssl

# Arch Linux
sudo pacman -Syu
sudo pacman -S openssl

# AlmaLinux 10.1
sudo dnf install -y openssl
```

## Creating PKI directory

``` sh
export PKI=$(pwd)/pki
```

### Create PKI hierarchy directories

To store private keys, certificates, and etc.

``` sh
mkdir -p "$PKI"/{root,ica/{web,vpn,internal}}/{certs,crl,newcerts,private,csr}
```

### Create serial files to keep track of issued and revoked certificates

``` sh
echo 1000 > "$PKI"/{root,ica/{web,vpn,internal}}/serial
echo 0100 > "$PKI"/{root,ica/{web,vpn,internal}}/crlnumber
```

### Create a text file to be used as a database for all certificates

``` sh
touch "$PKI"/{root,ica/{web,vpn,internal}}/index.txt
```

### Create an OpenSSL configuration to store all config and database related data

``` sh
cat >openssl.cnf.tpl <<EOF
[ ca ]
default_ca = ica_web_ca

[ root_ca ]
dir               = \$ENV::PKI/root
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand
private_key       = \$dir/private/ca.key
certificate       = \$dir/certs/ca.crt
crl               = \$dir/crl/ca.crl
crlnumber         = \$dir/crlnumber
crl_extensions    = crl_ext
default_days      = 7300
default_crl_days  = 30
default_md        = sha256
preserve          = no
email_in_dn       = no
name_opt          = ca_default
cert_opt          = ca_default
policy            = policy_strict
unique_subject    = no

[ ica_web_ca ]
dir               = \$ENV::PKI/ica/web
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand
private_key       = \$dir/private/ica-web.key
certificate       = \$dir/certs/ica-web.crt
crl_extensions    = crl_ext
default_days      = 1825
default_crl_days  = 30
default_md        = sha256
policy            = policy_strict
x509_extensions   = server_cert
copy_extensions   = copy

[ ica_vpn_ca ]
dir               = \$ENV::PKI/ica/vpn
certs             = \$dir/certs
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
private_key       = \$dir/private/ica-vpn.key
certificate       = \$dir/certs/ica-vpn.crt
crl_extensions    = crl_ext
default_days      = 1825
default_crl_days  = 30
default_md        = sha256
policy            = policy_strict
x509_extensions   = usr_cert

[ ica_internal_ca ]
dir               = \$ENV::PKI/ica/internal
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
private_key       = \$dir/private/ica-internal.key
certificate       = \$dir/certs/ica-internal.crt
crlnumber         = \$dir/crlnumber
crl_extensions    = crl_ext
default_days      = 1825
default_crl_days  = 30
default_md        = sha256
policy            = policy_strict
x509_extensions   = usr_cert

[ policy_strict ]
countryName             = match
stateOrProvinceName     = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits        = 4096
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256
prompt              = no

[ req_distinguished_name ]
countryName                     = AZ
0.organizationName              = DOST
commonName                      = DOST Root CA

#
# Extensions
#

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, keyCertSign, cRLSign

[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, keyCertSign, cRLSign
crlDistributionPoints  = URI:__CRL_URL__/crl/ca.crl
authorityInfoAccess = OCSP;URI:__CRL_URL__/ocsp

[ v3_ocsp ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = OCSPSigning

[ server_cert ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints       = CA:false
keyUsage               = critical, digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth
crlDistributionPoints  = URI:__CRL_URL__/crl/ica-web.crl
authorityInfoAccess = OCSP;URI:__CRL_URL__/ocsp

[ client_cert ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints       = CA:false
keyUsage               = critical, digitalSignature
extendedKeyUsage       = clientAuth
crlDistributionPoints  = URI:__CRL_URL__/crl/ica-web.crl
authorityInfoAccess = OCSP;URI:__CRL_URL__/ocsp

[ usr_cert ]
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer
basicConstraints        = CA:false
keyUsage                = critical, digitalSignature, keyEncipherment
extendedKeyUsage        = clientAuth
crlDistributionPoints   = URI:__CRL_URL__/crl/ica-web.crl
authorityInfoAccess = OCSP;URI:__CRL_URL__/ocsp

[ crl_ext ]
authorityKeyIdentifier = keyid:always,issuer
EOF
```

### Render the OpenSSL configuration

``` sh
CA_URL=http://ca.dost.edu.az
sed "s/__CRL_URL__/$(echo $CA_URL | sed 's/[\/&]/\\&/g')/g" openssl.cnf.tpl > openssl.cnf
```

## Issuing Certificates

### Root-CA

#### Generate a private key for CA using one the commands

``` sh
openssl genpkey \
  -algorithm EC \
  -pkeyopt ec_paramgen_curve:P-256 \
  -out "$PKI/root/private/ca.key"

openssl genrsa \
  -out "$PKI/root/private/ca.key" \
  4096

openssl ecparam \
  -genkey \
  -name prime256v1 \
  -out "$PKI/root/private/ca.key"
```

#### Secure the private key

``` sh
chmod 400 "$PKI/root/private/ca.key"
```

#### Generate CA certificate

- Using v3_ca extensions
- Expiring in 20 years (for a Root-CA)
- Skipping certificate requesting

``` sh
openssl req \
  -config openssl.cnf \
  -extensions v3_ca \
  -key "$PKI/root/private/ca.key" \
  -new \
  -x509 \
  -days 7300 \
  -sha256 \
  -out "$PKI/root/certs/ca.crt"
```

### Intermediate-CAs

#### Generate private keys for Inter-CA

``` sh
openssl genpkey \
  -algorithm EC \
  -pkeyopt ec_paramgen_curve:P-256 \
  -out "$PKI/ica/$ICA/private/ica-$ICA.key"
```

#### Secure the private keys

``` sh
chmod 400 "$PKI/ica/$ICA/private/ica-$ICA.key"
```

#### Generate a Certificate Request (CSR)

*countryName* and *organizationName* must **match** as we specified such
in the config

``` sh
openssl req \
  -new \
  -subj "/C=AZ/L=Baku/O=DOST/OU=DOST Call Center/CN=DOST ICA $(echo $ICA | tr '[:lower:]' '[:upper:]'
) 1" \
  -key "$PKI/ica/$ICA/private/ica-$ICA.key" \
  -out "$PKI/ica/$ICA/csr/ica-$ICA.csr"
```

#### Sign the CSR

Using v3_intermediate_ca extensions Expiring in 5 years (for an
Intermediate-CA)

``` sh
openssl ca \
  -config openssl.cnf \
  -name root_ca \
  -extensions v3_intermediate_ca \
  -batch \
  -notext \
  -days 1825 \
  -md sha256 \
  -in "$PKI/ica/$ICA/csr/ica-$ICA.csr" \
  -out "$PKI/ica/$ICA/certs/ica-$ICA.crt"
```

### Non-CA certificates

Examples on *ica_web_ca*

#### OCSP Certificate

##### Generate a private key for OCSP

``` sh
openssl genpkey \
  -algorithm EC \
  -pkeyopt ec_paramgen_curve:P-256 \
  -out "$PKI/ica/web/private/ocsp.key"
```

##### Secure the private key

``` sh
chmod 400 "$PKI/ica/web/private/ocsp.key"
```

##### Generate a Certificate Request (CSR)

``` sh
openssl req -new \
  -key "$PKI/ica/web/private/ocsp.key" \
  -subj "/C=AZ/L=Baku/O=DOST/OU=DOST Call Center/CN=OCSP Responder" \
  -out "$PKI/ica/web/csr/ocsp.csr"
```

##### Sign the CSR

Using v3_ocsp extensions Expiring in 2 years (for an OCSP certificate)

``` sh
openssl ca \
  -batch \
  -notext \
  -days 730 \
  -md sha256 \
  -config openssl.cnf \
  -extensions v3_ocsp \
  -in "$PKI/ica/web/csr/ocsp.csr" \
  -out "$PKI/ica/web/certs/ocsp.crt"
```

#### Server Certificate

##### Specify a domain

This example is focused on issuing a web certificate with a
*subjectAltName*

``` sh
export SERVER_FQDN=ha1.dost.edu.az
```

##### Generate a private key for Non-CA

``` sh
openssl genpkey \
  -algorithm EC \
  -pkeyopt ec_paramgen_curve:P-256 \
  -out "$PKI/ica/web/private/$SERVER_FQDN.key"
```

##### Secure the private key

``` sh
chmod 400 "$PKI/ica/web/private/$SERVER_FQDN.key"
```

##### Generate a Certificate Request (CSR)

``` sh
openssl req -new \
  -key "$PKI/ica/web/private/$SERVER_FQDN.key" \
  -subj "/C=AZ/L=Baku/O=DOST/OU=DOST Call Center/CN=$SERVER_FQDN" \
  -out "$PKI/ica/web/csr/$SERVER_FQDN.csr" \
  -addext "subjectAltName=DNS:$SERVER_FQDN"
```

##### Sign the CSR

Using server_cert extensions Expiring in a year (for a Non-CA)

``` sh
openssl ca \
  -config openssl.cnf \
  -name ica_web_ca \
  -extensions server_cert \
  -batch \
  -notext \
  -days 365 \
  -md sha256 \
  -in "$PKI/ica/web/csr/$SERVER_FQDN.csr" \
  -out "$PKI/ica/web/certs/$SERVER_FQDN.crt"
```

#### Client Certificate

##### Specify a user identifier

``` sh
export CLIENT_SUBJ=johndoe2@dost.edu.az
```

##### Generate a private key for Non-CA

``` sh
openssl genpkey \
  -algorithm EC \
  -pkeyopt ec_paramgen_curve:P-256 \
  -out "$PKI/ica/web/private/$CLIENT_SUBJ.key"
```

##### Secure the private key

``` sh
chmod 400 "$PKI/ica/web/private/$CLIENT_SUBJ.key"
```

##### Generate a Certificate Request (CSR)

``` sh
openssl req -new \
  -key "$PKI/ica/web/private/$CLIENT_SUBJ.key" \
  -subj "/C=AZ/L=Baku/O=DOST/OU=DOST Call Center/CN=$CLIENT_SUBJ" \
  -out "$PKI/ica/web/csr/$CLIENT_SUBJ.csr"
```

##### Sign the CSR

Using client_cert extensions Expiring in a year (for a Non-CA)

``` sh
openssl ca \
  -config openssl.cnf \
  -name ica_web_ca \
  -extensions client_cert \
  -batch \
  -notext \
  -days 365 \
  -md sha256 \
  -in "$PKI/ica/web/csr/$CLIENT_SUBJ.csr" \
  -out "$PKI/ica/web/certs/$CLIENT_SUBJ.crt"
```

## Certificate Revoking

### Revoke a Certificate

``` sh
openssl ca \
  -config openssl.cnf \
  -name ica_web_ca \
  -revoke "$PKI/ica/web/certs/ha3.dost.edu.az.crt"
```

### Deleting the revoked certificate's key

``` sh
rm -f "$PKI/ica/web/private/ha3.dost.edu.az.key"
```

### Generate Certificate Revoke List (CRL)

- Needs to be updated periodically, especially after a certificate gets
  revoked

For *ica_web_ca*

``` sh
openssl ca \
  -gencrl \
  -config openssl.cnf \
  -name ica_web_ca \
  -out "$PKI/ica/web/crl/ica-web.crl"
```

### View a CRL

``` sh
openssl crl \
  -text \
  -noout \
  -in "$PKI/ica/web/crl/ica-web.crl"
```

### Test a certificate against a CRL

``` sh
openssl verify \
  -CAfile "$PKI/ca-chain.crt" \
  -CRLfile "$PKI/crl-chain.crl" \
  -crl_check_all \
  "$PKI/ica/web/certs/johndoe2@dost.edu.az.crt"
```

## OCSP Server

### Run an OCSP server using OpenSSL

- Logging to /var/log/ocsp.log
- Serving revoked certificates by *ica_web_ca*

``` sh
#!/bin/sh

PORT=8001
PKI="$HOME/pki"
PKI_ICA="$PKI/ica/web"
LOG_FILE=/var/log/ocsp.log

sudo touch $LOG_FILE
sudo chown $(whoami):$(whoami) "$LOG_FILE"

exec openssl ocsp \
  -index "$PKI_ICA/index.txt" \
  -port $PORT \
  -rsigner "$PKI_ICA/certs/ocsp.crt" \
  -rkey "$PKI_ICA/private/ocsp.key" \
  -CA "$PKI_ICA/certs/ica-web.crt" \
  -ignore_err \
  2>&1 | tee "$LOG_FILE"
```

### Test a certificate against an OCSP server

``` sh
openssl ocsp \
  -CAfile "$PKI/ica/web/certs/ica-web.crt" \
  -issuer "$PKI/ica/web/certs/ica-web.crt" \
  -cert "$PKI/ica/web/certs/ha3.dost.edu.az.crt" \
  -url http://127.0.0.1:8001 \
  -resp_text \
  -noverify
```

## Extra commands

### Preview an X509 certificate

``` sh
openssl x509 -noout -text -in example.dost.edu.az.crt
```

### Combine certificates into a chain

``` sh
cat "$PKI/ica/web/certs/ica-web.crt" "$PKI/root/certs/ca.crt" > "$PKI/ca-chain.crt"
```

### Combine CRLs into a chain

``` sh
cat "$PKI/ica/web/crl/ica-web.crl" "$PKI/root/crl/ca.crl" > "$PKI/crl-chain.crl"
```

### Generate a PKCS12

``` sh
CLIENT_SUBJ=johndoe2@dost.edu.az
openssl pkcs12 -export \
  -in "$PKI/ica/web/certs/$CLIENT_SUBJ.crt" \
  -inkey "$PKI/ica/web/private/$CLIENT_SUBJ.key" \
  -certfile "$PKI/ca-chain.crt" \
  -out $CLIENT_SUBJ.p12 \
  -passout pass: \
  -name "$(echo $CLIENT_SUBJ | awk -F@ '{ print $1 }')"
```

### Generate a list of Intermediate-CAs

- web
- vpn
- internal
``` sh
PKI=pki
for ICA in web vpn internal
do
  # Generate private keys for Inter-CA
  openssl genpkey \
    -algorithm EC \
    -pkeyopt ec_paramgen_curve:P-256 \
    -out "$PKI/ica/$ICA/private/ica-$ICA.key"

  # Secure the private keys
  chmod 400 "$PKI/ica/$ICA/private/ica-$ICA.key"

  # Generate a Certificate Request (CSR)
  #
  # countryName and organizationName must
  # match like we specified in the config
  openssl req \
    -new \
    -subj "/C=AZ/L=Baku/O=DOST/OU=DOST Call Center/CN=DOST ICA $(echo $ICA | tr '[:lower:]' '[:upper:]'
) 1" \
    -key "$PKI/ica/$ICA/private/ica-$ICA.key" \
    -out "$PKI/ica/$ICA/csr/ica-$ICA.csr"

  # Sign the CSR
  #
  # v3_intermediate_ca extensions
  # 5 years for an Intermediate-CA
  openssl ca \
    -config openssl.cnf \
    -name root_ca \
    -extensions v3_intermediate_ca \
    -batch \
    -notext \
    -days 1825 \
    -md sha256 \
    -in "$PKI/ica/$ICA/csr/ica-$ICA.csr" \
    -out "$PKI/ica/$ICA/certs/ica-$ICA.crt"
done
```
