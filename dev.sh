#!/bin/bash -e

VM=debian
PID_FILE='tmp/pids/development.pid'
ALL_APPS="pandora"
RAILS_ENV=development

function usage {
  echo "Usage:"
  echo ""
  echo "  ./dev.sh <app> [<task>]"
  echo ""
  echo "  Available apps: ${ALL_APPS[*]}"
  echo "  Use 'all' as app to start all apps daemonized."
  echo ""
  echo "  Available tasks:"
  echo "    run: run app in foreground (default)"
  echo "    start: run app in background"
  echo "    stop: stop background app"
  echo "    restart: restart background app"
  exit 1
}

function pandora {
  TASK=$1
  cd /vagrant/pandora
  if [ $TASK == "run" ]; then
    bundle exec rails s -p 3000 -b 0.0.0.0
  elif [ $TASK == "start" ]; then
    mkdir -p $(dirname $PID_FILE)
    bundle exec rails s -p 3000 -b 0.0.0.0 -d -P $PID_FILE
  elif [ $TASK == "stop" ]; then
    kill_pid $(realpath $PID_FILE)
  fi
}

function kill_pid {
  FILE=$1
  if [ -f $FILE ]; then
    kill -9 $(cat $FILE)
    rm $FILE
  fi
}

if [ -z "$1" ] || [ "$1" == 'usage' ]; then
  usage
fi

VARGS="$@"
if [ -d /vagrant ]; then
  # echo "vagrant: $VARGS"

  APPS=$1
  TASK=${2:-run}
  if [ "$APPS" == 'all' ]; then
    APPS="$ALL_APPS"
  fi

  for APP in $APPS; do
    echo "PROMETHEUS: $APP task: ${TASK}"
    $APP $TASK || true
  done
else
  # echo "no vagrant: $VARGS"
  vagrant ssh -c "cd /vagrant && ./dev.sh $VARGS"
fi
