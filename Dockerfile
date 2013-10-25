FROM ubuntu:12.04

RUN apt-get -y update
RUN apt-get install -y ruby1.8 rubygems1.8
RUN apt-get install -y libxml2-dev libxslt-dev
RUN apt-get install -y libmagickwand-dev

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-client mysql-server libmysqld-dev

ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock

RUN cd /tmp && gem install bundler && bundle install
