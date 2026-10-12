#!/bin/bash

## Usage: heroku_backup_restore_latest [options] SOURCE_APP DEST_APP
##
## Restore latest backup from one app to another apps database
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
    
    SOURCE_APP="${1}"
    DEST_APP="${2}"

    LATEST_BACKUP=`heroku pg:backups --app $SOURCE_APP | awk 'NR==5{print $1; exit}'`
    DEST_DB_URL=`heroku pg --app $DEST_APP | grep -- "Add-on:" | awk '{print $NF'}`

    #echo $SOURCE_APP::$LATEST_BACKUP $DEST_DB_URL --app $DEST_APP --confirm $DEST_APP
    heroku pg:backups:restore $SOURCE_APP::$LATEST_BACKUP $DEST_DB_URL --app $DEST_APP --confirm $DEST_APP

    #show restores
    heroku pg:backups --app $DEST_APP
} 

set -e          # exit on command errors

main $@
