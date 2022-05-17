#!/bin/sh

CONF_FILE="/etc/vsftp/vsftp.conf"

if [ "$1" = "ftp" ]; then
 echo "Launching vsftp on ftp protocol"
 echo "pasv_max_port=${PASV_MAX_PORT}" >> $CONF_FILE
 echo "pasv_min_port=${PASV_MIN_PORT}" >> $CONF_FILE
fi

if [ "$1" = "ftps" ]; then
 echo "Launching vsftp on ftps protocol"
 CONF_FILE="/etc/vsftp/vsftp_ftps.conf"
 echo "pasv_max_port=${PASV_MAX_PORT}" >> $CONF_FILE
 echo "pasv_min_port=${PASV_MIN_PORT}" >> $CONF_FILE
fi

if [ "$1" = "ftps_implicit" ]; then
 echo "Launching vsftp on ftps protocol in implicit mode"
 CONF_FILE="/etc/vsftp/vsftp_ftps_implicit.conf"
 echo "pasv_max_port=${PASV_MAX_PORT}" >> $CONF_FILE
 echo "pasv_min_port=${PASV_MIN_PORT}" >> $CONF_FILE
fi

if [ "$1" = "ftps_tls" ]; then
 echo "Launching vsftp on ftps with TLS only protocol"
 CONF_FILE="/etc/vsftp/vsftp_ftps_tls.conf"
fi

if [ -n "$PASV_ADDRESS" ]; then
  echo "Activating passv on $PASV_ADDRESS"
  echo "pasv_address=$PASV_ADDRESS" >> $CONF_FILE
fi


# If no env var for FTP_USER has been specified, use 'ftpUser':
if [ "$FTP_USER" = "**String**" ]; then
    export FTP_USER='ftpUser'
fi

# If no env var has been specified, generate a random password for FTP_USER:
if [ "$FTP_PASS" = "**Random**" ]; then
    export FTP_PASS='Password@1'
fi

# Create home dir and update vsftpd user db:
mkdir -p "/home/vsftpd/${FTP_USER}"
chown -R ftp:ftp /home/vsftpd/

echo -e "${FTP_USER}\n${FTP_PASS}" > /etc/vsftpd/virtual_users.txt
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db
useradd -ms /bin/bash ${FTP_USER} && echo "${FTP_USER}:${FTP_PASS}" | chpasswd

# Set passive mode parameters:
if [ "$PASV_ADDRESS" = "**IPv4**" ]; then
    export PASV_ADDRESS=$(/sbin/ip route|awk '/default/ { print $3 }')
fi

# If TLS flag is set and no certificate exists, generate it
if [[ "$CONF_FILE" == *"ftps"* ]]
then
    chmod 755 /etc/vsftpd/private/vsftpd.pem
    chmod 755 /etc/vsftpd/private/vsftpd.key
fi

&>/dev/null /usr/sbin/vsftpd $CONF_FILE
