#!/bin/bash
# package:		Part of vpl-jail-system
# copyright:    Copyright (C) 2014 Juan Carlos Rodriguez-del-Pino
# license:      GNU/GPL, see LICENSE.txt or http://www.gnu.org/licenses/gpl.txt
# Description:  Script to install vpl-jail-system (Ubuntu 12 and CentOS)

function vpl_generate_selfsigned_certificate {
	echo "Generating self-signed SSL certificate"
	#Generate key
	openssl genrsa -passout pass:$PASSOPENSSL -des3 -out key.pem 1024
	#Generate certificate for this server
	local SUBJOPT="-subj"
	local SUBJ="/C=ES/ST=State/L=Location/O=VPL/OU=Execution server/CN=$FQDN"
	openssl req -new $SUBJOPT "$SUBJ" -key key.pem -out certini.pem -passin pass:$PASSOPENSSL
	#Remove key password
	cp key.pem keyini.pem
	openssl rsa -in keyini.pem -out key.pem -passin pass:$PASSOPENSSL
	#Generate self signed certificate for 5 years
	openssl x509 -in certini.pem -out cert.pem -req -signkey key.pem -days 1826
}

function vpl_change_pass {
	echo "changing password of jail"
	vim vpl-jail-system.conf -c ":%s/URLPATH=\//URLPATH=\/$PASSJAIL/g | :wq"
	echo $PASSJAIL > jailPass
}

function vpl_change_port {
	echo "changing port of jail"
	vim vpl-jail-system.conf -c ":%s/#PORT=80/PORT=$PORT/g | :wq"
	echo $PORT > jailPort
}

function vpl_change_secure_port {
	echo "changing secure port of jail"
	vim vpl-jail-system.conf -c ":%s/#SECURE_PORT=443/SECURE_PORT=$SECURE_PORT/g | :wq"
	echo $SECURE_PORT > jailSecurePort
}

if [ ! -f $VPLJAIL_INSTALL_DIR/jailPass ] ; then
	cd $VPLJAIL_INSTALL_DIR
	vpl_change_pass
else
	echo "Found edition in pass => Don't changed"
fi

if [ ! -f $VPLJAIL_INSTALL_DIR/jailPort ] ; then
	cd $VPLJAIL_INSTALL_DIR
	vpl_change_port
else
	echo "Found edition in port => Don't changed"
fi

if [ ! -f $VPLJAIL_INSTALL_DIR/jailSecurePort ] ; then
	cd $VPLJAIL_INSTALL_DIR
	vpl_change_secure_port
else
	echo "Found edition in secure port => Don't changed"
fi

if [ ! -f $VPLJAIL_INSTALL_DIR/cert.pem ] ; then
	cd /tmp/
	vpl_generate_selfsigned_certificate
	cp key.pem $VPLJAIL_INSTALL_DIR
	cp cert.pem $VPLJAIL_INSTALL_DIR
	chmod 600 $VPLJAIL_INSTALL_DIR/*.pem
	rm key.pem keyini.pem certini.pem cert.pem
else
	echo "Found SSL certificate => Don't create new one"
fi

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf