#!/bin/bash
# Script by Edward Stoever for Mariadb Support

# EDIT THE VARIABLES ACCORDINGLY
MARIADB_CLIENT="mariadb -u root --socket=/run/mysqld/mysqld.sock"
BINLOGDIR=/var/log/mysql
BINLOG_BASENAME=mariadb-bin
FIRSTBINLOG=${BINLOGDIR}/${BINLOG_BASENAME}.000002
STARTPOSITION=208286
LASTBINLOG=${BINLOGDIR}/${BINLOG_BASENAME}.000013
STOPPOSITION=51707

LOG_BIN=$($MARIADB_CLIENT  -ABNe "select VARIABLE_VALUE from information_schema.GLOBAL_VARIABLES where VARIABLE_NAME='LOG_BIN';")
if [ ! "${LOG_BIN}" == "OFF" ]; then echo "BINARY LOGGING SHOULD BE OFF."; exit; fi
$MARIADB_CLIENT -Ae "select 1" 1>/dev/null 2>&1 || echo "Mariadb client is not connecting."

# SANITIZE BINLOG NAMES
FIRSTBINLOG=$(echo ${FIRSTBINLOG} | sed "s/\/\//\//g"); LASTBINLOG=$(echo ${LASTBINLOG} | sed "s/\/\//\//g")
if [ ! -f ${FIRSTBINLOG} ]; then echo "Edit this script accordingly."; exit; fi

# A SIMPLE ARRAY, ALL BINLOGS IN ORDER:
unset STARTED ENDED BINLOGNAMES ALLBINLOGNAMES
ALLBINLOGNAMES=($(find ${BINLOGDIR} -name "${BINLOG_BASENAME}.*[0-9]" | sort))
# POPULATE A SUBARRAY STARTING AT $FIRSTBINLOG ENDING AT $LASTBINLOG
for (( k=0; k<${#ALLBINLOGNAMES[@]}; k++ )); do
if [ ! $ENDED ]; then
  if [ "${ALLBINLOGNAMES[$k]}" == "${FIRSTBINLOG}" ] || [ $STARTED ]; then
   STARTED=true;  
   BINLOGNAMES+=(${ALLBINLOGNAMES[$k]});
  fi
fi
if [ "${ALLBINLOGNAMES[$k]}" == "${LASTBINLOG}" ]; then ENDED=true; fi
done
unset ALLBINLOGNAMES


for (( j=0; j<${#BINLOGNAMES[@]}; j++ ));
do
if [ "$j" == "0" ]&&[ "$((${#BINLOGNAMES[@]} - 1))" == "0" ]; then
  # THIS BINLOG IS THE FIRST AND THE LAST
  echo "Applying binlog ${BINLOGNAMES[$j]} (first and last, ${STARTPOSITION} to ${STOPPOSITION})"
  mariadb-binlog --no-defaults --start-position=${STARTPOSITION} --stop-position=${STOPPOSITION} ${BINLOGNAMES[$j]} | $MARIADB_CLIENT
  
elif [ "$j" == "0" ]; then
  # THIS BINLOG IS THE FIRST
  echo "Applying binlog ${BINLOGNAMES[$j]} (first from position ${STARTPOSITION})"
  mariadb-binlog --no-defaults --start-position=${STARTPOSITION} ${BINLOGNAMES[$j]} | $MARIADB_CLIENT

elif  [ "$j" == "$((${#BINLOGNAMES[@]} - 1))" ]; then
  # THIS BINLOG IS THE LAST
  echo "Applying binlog ${BINLOGNAMES[$j]} (last to position ${STOPPOSITION})"
  mariadb-binlog --no-defaults --stop-position=${STOPPOSITION} ${BINLOGNAMES[$j]} | $MARIADB_CLIENT

else
  # THIS BINLOG IS NEITHER THE FIRST NOR THE LAST
  echo "Applying binlog ${BINLOGNAMES[$j]}"
  mariadb-binlog --no-defaults ${BINLOGNAMES[$j]} | $MARIADB_CLIENT
  
fi
done

$MARIADB_CLIENT -Ae "select * from MY_DB.MY_DB_TABLE where ROW_CREATED=(select max(ROW_CREATED) from MY_DB.MY_DB_TABLE);"


