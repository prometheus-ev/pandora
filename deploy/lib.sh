#!/bin/bash

# Copyright (c) 2014 Moritz Schepp <moritz.schepp@gmail.com>
# Distributed under the GNU GPL v3. For full terms see
# http://www.gnu.org/licenses/gpl-3.0.txt

# This is a deploy script for generic apps. Modify the deploy function to suit
# your needs.


# General configuration

TMPROOT=/tmp/deploy

# Variables

export TIMESTAMP=`date +"%Y%m%d%H%M%S"`
export REVISION=`git rev-parse $COMMIT`
export CURRENT_PATH="$DEPLOY_TO/releases/$TIMESTAMP"
export SHARED_PATH="$DEPLOY_TO/shared"
export LINKED_CURRENT_PATH="$DEPLOY_TO/current"

RED="\e[0;31m"
GREEN="\e[0;32m"
BLUE="\e[0;34m"
LIGHTBLUE="\e[1;34m"
NOCOLOR="\e[0m"


# Generic functions

function within_do {
  remote "cd $1 ; $2"
}

function remote {
  echo -e "${BLUE}$HOST${NOCOLOR}: ${LIGHTBLUE}$1${NOCOLOR}" 1>&2
  ssh -p $PORT $HOST "bash -c \"$1\""
  STATUS=$?

  if [[ $STATUS != 0 ]] ; then
    echo -e "${RED}deployment failed with status code $STATUS${NOCOLOR}"
    exit $STATUS
  fi
}

function local {
  echo -e "${BLUE}locally${NOCOLOR}: ${LIGHTBLUE}$1${NOCOLOR}" 1>&2
  bash -c "$1"
  STATUS=$?

  if [[ $STATUS != 0 ]] ; then
    echo -e "${RED}deployment failed with status code $STATUS${NOCOLOR}"
    exit $STATUS
  fi
}

function setup {
  remote "mkdir -p $DEPLOY_TO/releases"
  remote "mkdir -p $DEPLOY_TO/shared"
  remote "mkdir -p $DEPLOY_TO/shared/log.pandora"
  remote "mkdir -p $DEPLOY_TO/shared/log.rack-images"

  if [[ $COMMIT = staging ]] ; then
    remote "mkdir -p $DEPLOY_TO/shared/images"
    remote "mkdir -p $DEPLOY_TO/shared/log_archive"
    remote "mkdir -p $DEPLOY_TO/shared/stats"
    remote "mkdir -p $DEPLOY_TO/shared/uploads"
  fi
}

function deploy_code {
  TMPDIR=$TMPROOT/`pwgen 20 1`
  local "mkdir -p $TMPROOT"
  local "git clone $REPO $TMPDIR"
  local "cd $TMPDIR && git checkout $COMMIT && rm -rf $TMPDIR/.git"

  local "tar czf deploy.tar.gz -C $TMPDIR ."
  local "rm -rf $TMPDIR"
  local "scp -P $PORT deploy.tar.gz $HOST:$DEPLOY_TO/deploy.tar.gz"
  local "rm deploy.tar.gz"

  remote "mkdir $CURRENT_PATH"
  within_do $CURRENT_PATH "tar xzf ../../deploy.tar.gz"
  remote "chmod -R g+w $CURRENT_PATH"
  remote "find $CURRENT_PATH -type d -exec chmod o+rx {} \\;"
  remote "find $CURRENT_PATH -type f -exec chmod o+r {} \\;"
  remote "echo $REVISION > $CURRENT_PATH/REVISION"
  remote "echo $PHASE > $CURRENT_PATH/PHASE"
  remote "rm $DEPLOY_TO/deploy.tar.gz"
  remote "ln -sfn $CURRENT_PATH $DEPLOY_TO/current"
}

function cleanup {
  EXPIRED=`remote "(ls -t $DEPLOY_TO/releases | head -n $KEEP ; ls $DEPLOY_TO/releases) | sort | uniq -u | xargs"`
  for d in $EXPIRED ; do
    remote "rm -rf $DEPLOY_TO/releases/$d"
  done
}

function upload {
  echo -e "${BLUE}$HOST${NOCOLOR}: ${LIGHTBLUE}uploading local:$1 to remote:$2${NOCOLOR}" 1>&2
  cat $1 | ssh -p $PORT $HOST "cat > $2"
  STATUS=$?

  if [[ $STATUS != 0 ]] ; then
    echo -e "${RED}deployment failed with status code $STATUS${NOCOLOR}"
    exit $STATUS
  fi
}

function finalize {
  echo -e "${GREEN}deployment successful${NOCOLOR}"
}
