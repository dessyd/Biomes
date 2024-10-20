#!/bin/bash

source .env
RCON_HOST=Xmas
echo "Host: ${RCON_HOST}, World: ${WORLD_NAME}"
BUCKET=minecraft/${RCON_HOST:-mc}
SRC_DIR=./scripts
DEST_DIR=/tmp/${WORLD_NAME}

export RESTIC_REPOSITORY=s3:http://192.168.1.15:9000/${BUCKET}
# export RESTIC_PASSWORD_FILE=./restic-app/restic_password.txt
export RESTIC_PASSWORD
export RESTIC_HOST=${RCON_HOST}-backup
export AWS_PROFILE=restic




# echo $(date) > ${SRC_DIR}/date.txt

# if restic cat config >/dev/null 2>&1; then
#   echo "Repo ${RESTIC_REPOSITORY} is initialized"
# else
#   echo "Initilizing repo ${RESTIC_REPOSITORY}"
#   restic init
# fi

# echo "Backing up ${SRC_DIR}"
# restic -vv -vv backup --tag projectX --tag foo --tag bar ${SRC_DIR}

echo "Listing snapshots"
restic snapshots 
exit 0

# echo "listing files from latest snapshot"
# restic ls latest

# echo "Restoring latest snapshot to ${DEST_DIR}"
# restic restore latest --target ${DEST_DIR}
# ls -l ${DEST_DIR}
if [[ ${DEBUG,,} = true ]]; then
  set -x
fi

if (( $(ls "$SRC_DIR" | wc -l) == 1 )); then
  if restic cat config >/dev/null 2>&1; then
    if (($(restic snapshots --host ${RESTIC_HOST} | wc -l) > 1)); then
      echo "Restoring latest snapshot to ${DEST_DIR}"
      restic restore latest --target ${DEST_DIR} --host ${RESTIC_HOST}
    else
      echo "No backups available to restore"
    fi
  else
    echo "No repository available to restore from"
  fi
else
  echo "No restore needed"
fi