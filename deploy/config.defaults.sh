#!/bin/bash

# Copy this file to a new file named config.sh.
# Configure notify email addresses and your user name.

export REPO="."
export PORT="22"
export KEEP=15
export APPS="pandora rack-images"
export RUBY_VERSION="3.2.2"
export NOTIFY="dev@example.com ops@example.com"
export DEPLOYER="My name"
export DEPLOY_TO="/var/storage/host/prometheus"
export COMMIT="master"

function staging {
  export HOST="someone@staging.example.com"
}

function production {
  export HOST="someone@production.example.com"
}
