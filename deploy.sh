#!/bin/bash -e

TARGET=$1
HOME=$(dirname $(realpath $0))

if [[ "$TARGET" == "production" ]]; then
  echo "DEPLOYING MASTER BRANCH TO PRODUCTION"
  read -p "Type 'yes' if you want to proceed? " -r
  if ! [[ "$REPLY" == "yes" ]]; then
    echo "aborting"
    exit 1
  fi
fi

echo "DID YOU BUILD AND COMMIT ANY NEW FRONTEND CODE (npm run build)?"
read -p "Type 'yes' to proceed with the deploy? " -r
if ! [[ "$REPLY" == "yes" ]]; then
  echo "aborting"
  exit 1
fi

deploy/app.sh $TARGET
