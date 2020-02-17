#!/bin/bash
OUTDIR=/etc/openvpn/client-config
TEMFILE=/etc/openvpn/client-config/client.conf
KEY_DIR=/etc/openvpn/client
CRLFILE=/etc/openvpn/server/crl.pem
BASEDIR=/etc/openvpn/easy-rsa/3
function addUser() {
  ouser=$1
  if [ -f ${KEY_DIR}/${ouser}.key]; then
     echo "User is existing!"
     exit 1
  fi
  OUTFILE=/etc/openvpn/client-config/$ouser.ovpn
  echo "Adding User..."
  cd $BASEDIR
  ./easyrsa gen-req $ouser nopass
  if [$? -ne 0]; then
     echo "Running gen-req failed!"
     exit 1
  fi  
  ./easyrsa sign-req client $ouser
  if [$? -ne 0]; then
     echo "Running sign-request failed!"
     exit 1
  fi
  cp $BASEDIR/pki/issued/$ouser.crt $KEY_DIR
  cp $BASEDIR/pki/private/$ouser.key $KEY_DIR
  cat ${TEMFILE} \
      <(echo -e '<cert>') \
      ${KEY_DIR}/${ouser}.crt \
      <(echo -e '</cert>\n<key>') \
      ${KEY_DIR}/${ouser}.key \
      <(echo -e '</key>') \
      > ${OUTDIR}/${ouser}.ovpn
  echo "Output file for OpenVPN client is created at $OUTFILE"

function delUser() {
  duser=$1
  if [ ! -f ${KEY_DIR}/${ouser}.key ]; then
  echo "User not found!.Please check again"
  fi
  cd $BASEDIR
  ./easyrsa revoke $duser
  ./easyrsa gen-crl
  cp -rf pki/crl.pem $CRLFILE
  /etc/init.d/openvpn restart
  echo "User is deleted!"
   
} 
 
}
function main() {
if [! -f "$1"||"$2" ]; then
  echo "Please enter arguments again. "
  exit 1
fi
        username=$2
case "$1" in
  add)
        addUser $username
        ;;
  del)
        delUser $username
        ;;
  *)
        echo "Usage: ./openvpnUserMan.sh {add|del} user"
        exit 1
        ;;
esac
}
main $1 $2
