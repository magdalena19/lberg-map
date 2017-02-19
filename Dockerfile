FROM ruby:2.3.3-slim
MAINTAINER coderat@systemli.org

RUN apt-get update -qq && apt-get install -y \
	build-essential \
	libpq-dev \
    nodejs \
    imagemagick \
    ghostscript \
    supervisor \
    nodejs \
    git
RUN mkdir /ratmap
WORKDIR /ratmap
ADD Gemfile /ratmap/Gemfile
ADD Gemfile.lock /ratmap/Gemfile.lock
RUN bundle install
ADD . /ratmap
