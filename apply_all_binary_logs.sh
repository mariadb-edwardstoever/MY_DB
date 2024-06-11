#!/bin/bash
# Script by Edward Stoever for Mariadb Support

# EDIT THE VARIABLES ACCORDINGLY
MARIADB_CLIENT="mariadb -u root --socket=/run/mysqld/mysqld.sock"
BINLOGDIR=/var/log/mysql
BINLOG_BASENAME=mariadb-bin
FIRSTBINLOG=${BINLOGDIR}/${BINLOG_BASENAME}.000002
STARTPOSITION=208286

LOG_BIN=$($MARIADB_CLIENT  -ABNe "select VARIABLE_VALUE from information_schema.GLOBAL_VARIABLES where VARIABLE_NAME='LOG_BIN';")
if [ ! "${LOG_BIN}" == "OFF" ]; then echo "BINARY LOGGING SHOULD BE OFF."; exit; fi
$MARIADB_CLIENT -Ae "select 1" 1>/dev/null 2>&1 || echo "Mariadb client is not connecting."

# SANITIZE BINLOG NAMES
FIRSTBINLOG=$(echo ${FIRSTBINLOG} | sed "s/\/\//\//g"); LASTBINLOG=$(echo ${LASTBINLOG} | sed "s/\/\//\//g")
if [ ! -f ${FIRSTBINLOG} ]; then echo "Edit this script accordingly."; exit; fi

# A SIMPLE ARRAY, ALL BINLOGS IN ORDER:
unset STARTED BINLOGNAMES ALLBINLOGNAMES
ALLBINLOGNAMES=($(find ${BINLOGDIR} -name "${BINLOG_BASENAME}.*[0-9]" | sort))
# POPULATE A SUBARRAY STARTING AT $FIRSTBINLOG
for (( k=0; k<${#ALLBINLOGNAMES[@]}; k++ )); do
  if [ "${ALLBINLOGNAMES[$k]}" == "${FIRSTBINLOG}" ] || [ $STARTED ]; then
   STARTED=true;
   BINLOGNAMES+=(${ALLBINLOGNAMES[$k]});
  fi
done
unset ALLBINLOGNAMES

for (( j=0; j<${#BINLOGNAMES[@]}; j++ ));
do
if [ "$j" == "0" ]; then
  # THIS BINLOG IS THE FIRST
  echo "Applying binlog ${BINLOGNAMES[$j]} (first from position ${STARTPOSITION})"
  mariadb-binlog --no-defaults --start-position=${STARTPOSITION} ${BINLOGNAMES[$j]} | $MARIADB_CLIENT

else
  # THIS BINLOG IS NOT THE FIRST
  echo "Applying binlog ${BINLOGNAMES[$j]}"
  mariadb-binlog --no-defaults ${BINLOGNAMES[$j]} | $MARIADB_CLIENT

fi
done

$MARIADB_CLIENT -Ae "select * from MY_DB.MY_DB_TABLE where ROW_CREATED=(select max(ROW_CREATED) from MY_DB.MY_DB_TABLE);"
$MARIADB_CLIENT -Ae "select * from MY_DB.MY_DB_TABLE where ROW_UPDATED=(select max(ROW_UPDATED) from MY_DB.MY_DB_TABLE);"
$MARIADB_CLIENT -Ae "checksum table MY_DB.MY_DB_TABLE;"

