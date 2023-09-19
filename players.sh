#!/bin/bash
CURR_DIR=${PWD##*/} 
CURR_SCRIPT=`echo "$(basename $0)" | cut -d'.' -f1`
MSG=`docker-compose exec -i mc rcon-cli list`
echo "$(date) [${CURR_SCRIPT}] ${CURR_DIR}: ${MSG}"
