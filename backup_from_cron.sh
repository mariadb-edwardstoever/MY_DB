#!/bin/bash
BASEDIR=/BACKUPS
BACKUPDIR=${BASEDIR}/mariabackup_$(date +"%Y-%d-%m-%H-%M")
mkdir -p ${BACKUPDIR}
chown -R mysql:mysql ${BASEDIR}
mariabackup --user=root --backup --target-dir=${BACKUPDIR}

