#!/bin/bash
# Script by Edward Stoever for Mariadb Support

# EDIT THE VARIABLES ACCORDINGLY
TARGETDIR=/BACKUPS/mariabackup_2024-07-06-16-40
DATADIR=/var/lib/mysql

if [ ! -d ${TARGETDIR} ]; then echo "Edit this script accordingly."; exit; fi
systemctl stop mariadb
rm -fr ${DATADIR}/*
mariabackup --prepare --target-dir=${TARGETDIR} 
mariabackup --copy-back --target-dir=${TARGETDIR}
chown -R mysql:mysql ${DATADIR}
systemctl start mariadb

