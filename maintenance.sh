#!/bin/bash -e

# USAGE
# ./maintenance.sh master on '2 hours'

# code

TARGET=$1
STATE=$2
DURATION=${3:-2 hours}

if [[ "$TARGET" == "" ]]; then
  echo "please provide a target (production or staging)"
  exit 1
fi

if [[ "$STATE" == "" ]]; then
  echo "please provide a maintenance state to apply (on or off)"
  exit 1
fi


function configure {
  source deploy/config.defaults.sh
  source deploy/config.sh
  $1
  source deploy/lib.sh
}

configure $TARGET


if [[ "$STATE" == "on" ]]; then
  echo "$TARGET: setting maintenance mode to $STATE, showing duration $DURATION"
  echo 'on'
  TS=$(date -d "$DURATION" +"%FT%H:%M:00")
  echo "{\"until\": \"$TS\"}" > current.json
  upload current.json "$SHARED_PATH/maintenance.json"
  upload pandora/public/maintenance/index.html "$LINKED_CURRENT_PATH/pandora/public/maintenance/index.html"
  upload pandora/public/maintenance/style.css "$LINKED_CURRENT_PATH/pandora/public/maintenance/style.css"
  upload pandora/public/maintenance/favicon.ico "$LINKED_CURRENT_PATH/pandora/public/maintenance/favicon.ico"
  upload pandora/public/maintenance/trademark.svg "$LINKED_CURRENT_PATH/pandora/public/maintenance/trademark.svg"
  rm current.json
else
  echo "$TARGET: setting maintenance mode to $STATE"
  remote "rm -f $SHARED_PATH/maintenance.json"
fi
