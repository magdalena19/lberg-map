FROM ruby:2.3.3-slim
MAINTAINER coderat@systemli.org

RUN apt-get update -qq && apt-get install -y \
	build-essential \
	libpq-dev \
  nodejs \
  imagemagick \
  ghostscript \
  git \
  supervisor \
  phantomjs
RUN mkdir /lbergmap
WORKDIR /lbergmap
ADD Gemfile /lbergmap/Gemfile
ADD Gemfile.lock /lbergmap/Gemfile.lock
RUN bundle install
ADD . /lbergmap
