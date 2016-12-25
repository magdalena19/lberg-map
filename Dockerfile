# defines which mages should be used, which software installed in the 
# webapp container
#FROM ruby:2.3.1
FROM ruby:2.3.3-slim
RUN apt-get update -qq && apt-get install -y \
	build-essential \
	libpq-dev \
	nodejs \
	imagemagick \
    ghostscript \
    libsqlite3-dev \
    supervisor
RUN mkdir /lbergmap
WORKDIR /lbergmap
ADD Gemfile /lbergmap/Gemfile
ADD Gemfile.lock /lbergmap/Gemfile.lock
RUN bundle install
ADD . /lbergmap
