#!/bin/bash

## Usage: backup_github_repo [options] REPO BUCKET
##
## Clones the repo from github
## Syncs to s3 bucket BUCKET/REPOS
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

    REPO="${1}"
    BUCKET="${2}"
    LOCAL=${REPO##*/}

    git clone https://"$GITHUB_OAUTH"@github.com/"$REPO"

    aws s3 sync ./"$LOCAL" s3://$BUCKET/REPOS/$LOCAL
}

set -e          # exit on command errors

main $@        
