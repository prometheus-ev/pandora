#!/bin/bash -ev

TEST_ROOT="$( cd "$( dirname "$0" )" && pwd )"

# rack-images
cd $TEST_ROOT/rack-images
touch tmp/restart.txt

# pandora
cd $TEST_ROOT/pandora
touch tmp/restart.txt
rm -rf tmp/cache/active_cache/*
bundle exec rails test -v test
HEADLESS=true bundle exec rails test -v test/system
