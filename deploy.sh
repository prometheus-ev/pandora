#!/bin/bash -e

BRANCH=$1
TARGET=$2
HOME=$(dirname $(realpath $0)) # TODO: what is this?

if [[ "$TARGET" == "" && "$BRANCH" == "production" ]]; then
  BRANCH=master
  TARGET=production
fi

# fail if branch or target aren't specified
if [[ "$TARGET" == "" || "$BRANCH" == "" ]]; then
  echo "please provide a branch and a deploy target"
  exit 1
fi

if [[ "$TARGET" == "production" ]]; then
  echo "DEPLOYING BRANCH '$BRANCH' TO PRODUCTION"
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

# pass the branch name to the deploy script
export COMMIT_OVERRIDE=$BRANCH

deploy/app.sh $TARGET
