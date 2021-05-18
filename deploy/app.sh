#!/bin/bash -e

function deploy {
  setup
  deploy_code
  cleanup

  # shared
  remote "ln -sfn $SHARED_PATH/env $CURRENT_PATH/.env"

  # pandora
  if [[ " $APPS " =~ .*\ pandora\ .* ]]; then
    CURRENT=$CURRENT_PATH/pandora
    remote "echo $RUBY_VERSION > $CURRENT/.ruby-version"
    remote "ln -sfn $SHARED_PATH/database.pandora.yml $CURRENT/config/database.yml"
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

  remote "echo 'Revision: $REVISION' | mail -s 'deployed $DEPLOY_TARGET' $NOTIFY"

  finalize
}

function configure {
  source deploy/config.sh
  $1
  source deploy/lib.sh
}

export DEPLOY_TARGET=$1

configure $DEPLOY_TARGET
deploy
