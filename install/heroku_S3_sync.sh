#!/bin/bash

## Usage: heroku_S3_sync [options] SOURCE_BUCKET_FOLDER DEST_BUCKET_FOLDER
##
## One way sync from SOURCE to DEST. Do not include S3 protocol or trailing slash e.g.
## heroku_S3_sync bucket1/folder1 bucket2/folder2
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

    SOURCE_FOLDER="${1}"
    DEST_FOLDER="${2}"

    if [[ "$DEST_FOLDER" =~ ^production ]]; then
        echo $DEST_FOLDER" is not an allowed destination"
        exit 1
    fi

    aws s3 sync s3://$SOURCE_FOLDER/ s3://$DEST_FOLDER/ --exact-timestamps
} 

set -e          # exit on command errors

main $@
