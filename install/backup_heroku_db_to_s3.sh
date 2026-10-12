#!/bin/bash

## Usage: backup_heroku_database [options] APP BUCKET
##
## Downloads the lastest database backup from Heroku --app APP
## Uploads to s3 bucket BUCKET/APP/latest.dump with server side encryption
##
## Options:
##   -h, --help    Display this message.
##

if [ "on" != "${HEROKU_SCHEDULER_STATUS,,}" ]; then
  echo "Heroku Scheduler is set to "$HEROKU_SCHEDULER_STATUS
  exit 1
fi

usage() {
  [ "$*" ] && echo "$0: $*"
  sed -n '/^##/,/^$/s/^## \{0,1\}//p' "$0"
  exit 2
} 2>/dev/null

main() {
    if [ $# -eq 0 ];
        then usage 2>&1
    fi
    
    while [ $# -gt 0 ]; do
        case $1 in
            (-h|--help) usage 2>&1;;
            (--) break;;
            (-*) usage "$1: unknown option";;
            (*)  break;;
        esac
        shift
    done
  
    APP="${1}"
    BUCKET="${2}"
  
    heroku pg:backups:download --app $APP
    
    #get latest dump file
    latest=`ls -t ./latest.dump* | head -1`
    
    aws s3 cp $latest s3://$BUCKET/$APP/latest.dump --sse AES256
}

set -e          # exit on command errors

main $@
