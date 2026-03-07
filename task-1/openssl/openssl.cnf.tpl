[ ca ]
default_ca = ica_web_ca

[ root_ca ]
dir               = $ENV::PKI/root
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand
private_key       = $dir/private/ca.key
certificate       = $dir/certs/ca.crt
crl               = $dir/crl/ca.crl
crlnumber         = $dir/crlnumber
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
dir               = $ENV::PKI/ica/web
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand
private_key       = $dir/private/ica-web.key
certificate       = $dir/certs/ica-web.crt
crl_extensions    = crl_ext
default_days      = 1825
default_crl_days  = 30
default_md        = sha256
policy            = policy_strict
x509_extensions   = server_cert
copy_extensions   = copy

[ ica_vpn_ca ]
dir               = $ENV::PKI/ica/vpn
certs             = $dir/certs
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
private_key       = $dir/private/ica-vpn.key
certificate       = $dir/certs/ica-vpn.crt
crl_extensions    = crl_ext
default_days      = 1825
default_crl_days  = 30
default_md        = sha256
policy            = policy_strict
x509_extensions   = usr_cert

[ ica_internal_ca ]
dir               = $ENV::PKI/ica/internal
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
private_key       = $dir/private/ica-internal.key
certificate       = $dir/certs/ica-internal.crt
crlnumber         = $dir/crlnumber
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
