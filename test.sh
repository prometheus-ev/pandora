#!/bin/bash -e

if ! [ -d /vagrant ]; then
  echo "called from outside vagrant vm, switching to vm"
  vagrant ssh -c "/vagrant/test.sh"
  exit 0
fi

TEST_ROOT="$( cd "$( dirname "$0" )" && pwd )"

# pandora

cd $TEST_ROOT/pandora
touch tmp/restart.txt # TODO: why are we doing this?
rm -rf tmp/cache/active_cache/*
rm -rf tmp/coverage/

export COVERAGE=true
export HEADLESS=true
export PM_RETRY_TESTS=true

bundle exec rails test -v test
sleep 5
bundle exec rails test -v test/system
