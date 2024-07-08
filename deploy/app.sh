#!/bin/bash -e

function deploy {
  if [[ "$DEPLOYER" == "" ]]; then
    echo "DEPLOYER is unset, please fill it in with something like your name in"
    echo "'deploy/config.sh'."
    exit 1
  fi

  OLD_COMMIT=$(ssh -p $PORT $HOST "cat $LINKED_CURRENT_PATH/BRANCH") || :

  if [[ "$OLD_COMMIT" != "$COMMIT" ]]; then
    echo "BRANCH '$OLD_COMMIT' IS DEPLOYED ON THIS TARGET, YOU ARE DEPLOYING '$COMMIT'"
    read -p "Type 'yes' if you want to proceed? " -r
    if ! [[ "$REPLY" == "yes" ]]; then
      echo "aborting"
      exit 1
    fi
  fi

  setup
  deploy_code
  cleanup

  # shared
  remote "ln -sfn $SHARED_PATH/env $CURRENT_PATH/.env"

  # pandora
  if [[ " $APPS " =~ .*\ pandora\ .* ]]; then
    CURRENT=$CURRENT_PATH/pandora
    remote "echo $RUBY_VERSION > $CURRENT/.ruby-version"
    # remote "ln -sfn $SHARED_PATH/database.pandora.yml $CURRENT/config/database.yml"
    remote "ln -sfn $SHARED_PATH/terms_of_use.en.pdf $CURRENT/public/docs/terms_of_use.en.pdf"
    remote "ln -sfn $SHARED_PATH/terms_of_use.de.pdf $CURRENT/public/docs/terms_of_use.de.pdf"
    remote "ln -sfn $SHARED_PATH/log.pandora $CURRENT/log"
    remote "cd $CURRENT && bundle config set --local path '$SHARED_PATH/bundle.$RUBY_VERSION'"
    remote "cd $CURRENT && bundle config set --local without 'development:test'"
    remote "cd $CURRENT && bundle install --quiet"
    remote "touch $CURRENT_PATH/pandora/tmp/refresh_translations.txt"
    remote "cd $CURRENT && RAILS_ENV=production bundle exec rake db:migrate"
    remote "cd $CURRENT && RAILS_ENV=production bundle exec rake pandora:etc"
  fi

  # rack-images
  if [[ " $APPS " =~ .*\ rack-images\ .* ]]; then
    CURRENT=$CURRENT_PATH/rack-images
    remote "echo $RUBY_VERSION > $CURRENT/.ruby-version"
    remote "ln -sfn $SHARED_PATH/log.rack-images $CURRENT/log"
    remote "cd $CURRENT && bundle config set --local path '$SHARED_PATH/bundle.$RUBY_VERSION'"
    remote "cd $CURRENT && bundle config set --local without 'development:test'"
    remote "cd $CURRENT && bundle install --quiet"
  fi

  # restart
  remote "touch $CURRENT_PATH/pandora/tmp/restart.txt"
  remote "touch $CURRENT_PATH/rack-images/tmp/restart.txt"

  remote "echo '$COMMIT' > $CURRENT_PATH/BRANCH"
  remote "echo 'Revision: $REVISION ($COMMIT)' | mail -s '$DEPLOYER deployed $DEPLOY_TARGET' $NOTIFY" || :

  finalize
}

function configure {
  source deploy/config.defaults.sh
  source deploy/config.sh
  $1
  source deploy/lib.sh

  export COMMIT=$COMMIT_OVERRIDE
}

export DEPLOY_TARGET=$1

configure $DEPLOY_TARGET

if [ "$DRY_RUN" == "true" ]; then
  echo "Dry run mode: no deployments were made"
  echo "--- settings:"
  echo "REPO: $REPO"
  echo "PORT: $PORT"
  echo "KEEP: $KEEP"
  echo "APPS: $APPS"
  echo "RUBY_VERSION: $RUBY_VERSION"
  echo "HOST: $HOST"
  echo "DEPLOY_TO: $DEPLOY_TO"
  echo "NOTIFY: $NOTIFY"
  echo "COMMIT: $COMMIT"
  echo "---"
  exit
fi

deploy