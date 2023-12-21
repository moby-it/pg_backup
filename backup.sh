#!/bin/bash


log() {
    local current_date=$(date +"%Y-%m-%d %H:%M:%S")
    printf "[$current_date] $1\n"
}
# PostgreSQL Backup Script

# Connection string as an argument


CONNECTION_STRING=$(cat connection_string)
# check if connection string is null
if [[ -z $CONNECTION_STRING ]];
then
  echo "No connection string provided"
  exit 1
fi
log "Connection String: $CONNECTION_STRING"

# Extracting details from the connection string
# Format of connection string: "postgresql://username:password@host:port/dbname"
USER=$(echo $CONNECTION_STRING | cut -d'/' -f3 | cut -d':' -f1)
PASSWORD=$(echo $CONNECTION_STRING | cut -d':' -f3 | cut -d'@' -f1)
HOST=$(echo $CONNECTION_STRING | cut -d'@' -f2 | cut -d':' -f1)
PORT=$(echo $CONNECTION_STRING | cut -d':' -f4 | cut -d'/' -f1)
DBNAME=$(echo $CONNECTION_STRING | cut -d'/' -f4)

# Set the PGPASSWORD environment variable for non-interactive password input
export PGPASSWORD=$PASSWORD

# Backup filename
BACKUP_FILENAME="${DBNAME}_$(date +%Y%m%d_%H%M%S).sql"

# checking if s3cmd is installed
if ! command -v s3cmd &> /dev/null
then 
  echo "s3cmd does not exists, exiting backup"
  exit 1
fi

# Perform the backup

log "Starting pg_dump.."

pg_dump -h $HOST -p $PORT -U $USER $DBNAME > $BACKUP_FILENAME 2> pg_dump_err

if [[ ! -z $(cat pg_dump_err) ]]
then
  echo $(cat pg_dump_err)
  exit 1
fi

# Unset the PGPASSWORD environment variable
unset PGPASSWORD

log "Backup of $DBNAME completed: $BACKUP_FILENAM"

log "Sending back up to s3..."

BUCKET_NAME=s3://ps-backups
s3cmd mb $BUCKET_NAME || { echo "failed to create bucket"; exit 1;}
s3cmd put $BACKUP_FILENAME $BUCKET_NAME || { echo "failed to upload file"; exit 1; } 

log "Back up sent to s3 succesfully"
exit 0
