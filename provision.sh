#!/bin/bash -e

# General configuration

RUBY_VERSION=3.2.2
ELASTICSEARCH_VERSION=7.17.1

function debian_basics {
  apt-get update --allow-releaseinfo-change
  apt-get install -y \
    build-essential libxml2-dev libxslt-dev libssl-dev git-core \
    libreadline-dev zlib1g-dev mariadb-server default-libmysqlclient-dev \
    libmagickwand-dev libmagic-dev libpq-dev apt-transport-https curl htop \
    default-jre net-tools chromium-driver imagemagick pwgen zip idn ffmpeg zst \
    libyaml-dev

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html
  echo vm.max_map_count=262144 > /etc/sysctl.d/vm_max_map_count.conf
  sysctl --system

  # fix imagemagick to allow PDF parsing
  sed -i -E 's/^.*policy domain="coder" rights="none" pattern="PDF".*$//' /etc/ImageMagick-6/policy.xml

  # configure mysql to listen on all interfaces and allow connections
  sed -i -E "s/bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/" /etc/mysql/mariadb.conf.d/50-server.cnf
  systemctl restart mariadb
  mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root'"
  mysql -e "DROP USER 'root'@'localhost'"
  mysql -u root -proot -e "FLUSH PRIVILEGES"

  # elasticsearch (development & test)
  useradd -m elasticsearch
  mkdir /opt/elastic
  cd /opt/elastic
  wget -O elastic.tar.gz "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION-linux-x86_64.tar.gz"
  mkdir elasticsearch
  tar xzf elastic.tar.gz --directory elasticsearch --strip-components=1
  rm elastic.tar.gz

  mv elasticsearch development
  echo -e '-Xms1g\n-Xmx1g' > development/config/jvm.options.d/memory.options
  sed -i -E "/^#\s*?node.name:.*$/a node.name: node-1" development/config/elasticsearch.yml
  sed -i -E "/^#\s*?network.host:.*$/a network.host: 0.0.0.0" development/config/elasticsearch.yml
  sed -i -E "/^#\s*?http.port:.*$/a transport.port: 9300-9349" development/config/elasticsearch.yml
  sed -i -E "/^#\s*?discovery.seed_hosts:.*$/a discovery.seed_hosts: [\"0.0.0.0:9300\"]" development/config/elasticsearch.yml
  sed -i -E "/^#\s*?cluster.initial_master_nodes:.*$/a cluster.initial_master_nodes: [\"node-1\"]" development/config/elasticsearch.yml
  sed -i -E "/^#\s*?action.destructive_requires_name:.*$/a action.destructive_requires_name: false" development/config/elasticsearch.yml
  sed -i -E "/^#\s.*configuring-stack-security.html.*$/a xpack.security.enabled: false" development/config/elasticsearch.yml
  chown -R elasticsearch: development

  cp -a development test
  echo -e '-Xms1g\n-Xmx1g' > test/config/jvm.options.d/memory.options
  sed -i -E "/^#\s*?cluster.name:.*$/a cluster.name: test" test/config/elasticsearch.yml
  sed -i -E "/^#\s*?http.port:.*$/a http.port: 9201" test/config/elasticsearch.yml
  sed -i -E "s/^\s*?transport.port:.*$/transport.port: 9350-9400/" test/config/elasticsearch.yml
  sed -i -E "s/^\s*?discovery.seed_hosts:.*$/discovery.seed_hosts: [\"0.0.0.0:9350\"]/" test/config/elasticsearch.yml
  chown -R elasticsearch: test

  cp /vagrant/deploy/elasticsearch-development.service /etc/systemd/system/
  cp /vagrant/deploy/elasticsearch-test.service /etc/systemd/system/
  systemctl daemon-reload

  # unknown why this is needed
  rm -f /opt/elastic/development/config/elasticsearch.keystore.tmp
  rm -f /opt/elastic/test/config/elasticsearch.keystore.tmp

  systemctl start elasticsearch-development elasticsearch-test
  sleep 5 # let elasticsearch start up
  cp /vagrant/.java.policy /home/elasticsearch/
  systemctl restart elasticsearch-development elasticsearch-test
}

function centos_basics {
  yum groupinstall -y 'Development Tools'

  yum install -y \
    libxml2-devel libxslt-devel libss-devel git readline-devel zlibrary-devel \
    mysql-server java-1.8.0-openjdk ImageMagick \
    openssl-devel ImageMagick-devel file file-devel mysql-devel

  # for pdf genesis
  yum install -y texlive-latex texlive

  chkconfig mysqld on
  service mysqld start
  mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('root') WHERE Host LIKE '\%'"
  mysql -u root -e "FLUSH PRIVILEGES"

  # and elasticsearch
  wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.4.6/elasticsearch-2.4.6.rpm -O elastic.rpm
  yum install -y elastic.rpm
  rm elastic.rpm
  chkconfig elasticsearch on
  service elasticsearch start
  sleep 5
  cp -a /vagrant/pandora/config/synonyms/ /var/lib/elasticsearch/elasticsearch/nodes/0/
  service elasticsearch restart
}

function install_rbenv {
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  echo 'export PATH="~/.rbenv/bin:$PATH"' >> ~/.bash_profile
  echo 'export PATH="~/.rbenv/shims:$PATH"' >> ~/.bash_profile
  source ~/.bash_profile

  rbenv install $RUBY_VERSION
  rbenv global $RUBY_VERSION

  # install both versions of bundler
  gem install bundler -v '< 2'
  gem install bundler -v '>= 2'
}

function install_nvm {
  git clone https://github.com/nvm-sh/nvm.git ~/.nvm
  cd ~/.nvm
  git checkout v0.37.2

  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bash_profile
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bash_profile
  echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bash_profile

  . nvm.sh

  nvm install lts/erbium
}

function prepare_for_pandora {
  cd /vagrant/pandora
  cd public/docs
  ln -sfn sample.pdf terms_of_use.en.pdf
  ln -sfn sample.pdf terms_of_use.de.pdf

  bundle

  bundle exec rake db:drop db:create db:schema:load db:seed
  RAILS_ENV=test bundle exec rake db:drop db:create db:schema:load db:seed
  # bundle exec rake pandora:generate:terms_of_use
}

function prepare_for_rack_images {
  cd /vagrant/rack-images
  bundle
}

$1
