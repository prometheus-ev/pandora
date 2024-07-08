#!/bin/bash -e

ARGS=$@

if ! [ -d /vagrant ]; then
  echo "called from outside vagrant vm, switching to vm"
  vagrant ssh -c "/vagrant/test.sh $ARGS"
  exit 0
fi

TEST_ROOT="$( cd "$( dirname "$0" )" && pwd )"

# pandora

cd $TEST_ROOT/pandora
rm -rf tmp/cache/active_cache/*
rm -rf tmp/coverage/

export COVERAGE="true"
export HEADLESS="true"
export PM_RETRY_TESTS="true"
export TEST_OPTS='--verbose --exclude "/@(brittle|skip)/"'

echo 'running rubocop'
if ! bundle exec bin/audit ; then
  echo "... failed: see ./pandora/tmp/rubocop/report.html"
  exit 1
fi

function test_all {
  bundle exec rails test $TEST_OPTS test
  sleep 5
  bundle exec rails test $TEST_OPTS test/system
}

echo $ARGS

if [ "$ARGS" = "brittle" ]; then
  echo "running only brittle tests"
  COVERAGE="false"
  TEST_OPTS='--verbose --name "/@brittle/"'
  test_all
  exit 0
fi

if [ "$ARGS" = "skipped" ]; then
  echo "running only skipped tests"
  COVERAGE="false"
  TEST_OPTS='--verbose --name "/@skip/"'
  test_all
  exit 0
fi

if ! [[ -z "$ARGS" ]]; then
  COVERAGE="false"
  bundle exec rails test $TEST_OPTS $ARGS
  exit 0
fi

test_all
