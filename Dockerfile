FROM ruby:2.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs imagemagick ghostscript

ADD . /lberg-map
WORKDIR /lberg-map

RUN bundle install