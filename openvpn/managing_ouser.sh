#!/bin/bash
OUTDIR=/etc/openvpn/client-config
KEYDIR=/etc/openvpn/client
TEMPFILE=/etc/openvpn/client-config/client
RUNDIR=/etc/openvpn/easyrsa/3
RUNFILE=/etc/openvpn/easyrsa/3/easyrsa
function adduser() {
arg1=$1
#arg2=$2
if [$arg1 == ""]; {
echo "Nothing is enter for creating. Try again!"
exit 1
}
echo "Adding..."
$RUNFILE gen-req $arg1 nopass
$RUNFILE sign-req client $arg1
cp ${RUNDIR}/pki/issued/${arg1}.crt $KEYDIR
cp ${RUNDIR}/pki/private/${arg1}.key $KEYDIR
echo "Done."
}

