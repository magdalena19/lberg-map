# **RatMap**

**A Ruby on Rails 4 application for collaboratively mapping and sharing points of interest on a website**

  [![Build Status](https://travis-ci.org/magdalena19/lberg-map.svg?branch=master)](https://travis-ci.org/magdalena19/lberg-map)
  [![Code Climate](https://codeclimate.com/github/magdalena19/lberg-map/badges/gpa.svg)](https://codeclimate.com/github/magdalena19/lberg-map)
  [![Test Coverage](https://codeclimate.com/github/magdalena19/lberg-map/badges/coverage.svg)](https://codeclimate.com/github/magdalena19/lberg-map/coverage)

## **Features**

* **Individual maps**: Create _public_, _semi-public_ or _private maps_ as a registered user or guest
* **Share maps**: Invite others to see what you've contributed or embed your map on other websites
* **Reviewing contributions**: Let guests contribute POIs on public maps and either accept or revert their entries as map admin
* **Multi-language support**: Optionally machine-translate to other languages supported by the system (so far english and german)

Check out the **[Demo](https://korner.lynx.uberspace.de)** either as
* guest
* user (_user@test.com / secret_)
* Access a [password-protected map](https://korner.lynx.uberspace.de/en/secret5) with password 'secret'

## **System prerequisits**
#### **Ruby**
  This application was written and tested under Ruby version 2.3.1. Installation via [RVM](https://rvm.io/) recommended.



  _Note that you have to upgrade to Rails 4.2.8+ if you want to use Ruby v2.4+ due to [compatibility issues](https://weblog.rubyonrails.org/2017/2/21/Rails-4-2-8-has-been-released/)!_

#### **Databases**
* **[PostgreSQL](https://www.postgresql.org/)** (9.3 or a later version), the most relevant packages on a UNIX/Linux based system are `postgresql-server-dev-9.[version-no]`, `postgresql-9.[version-no]`
	* `sudo apt install postgresql`
* **[Redis](https://redis.io/)** The application makes use of background processing in some parts, hence it is neccessary to to install and run an instance.
	* `sudo apt-get install redis-server`

#### **Other dependencies**
	* Deps currently nessaceray but ugly
		* `sudo apt install postgresql-server-dev-9.6`
		* `sudo apt install nodejs`
  * [Imagemagik](https://www.imagemagick.org/) for normal captchas
	* `sudo apt install imagemagick`


## **Application configuration**
Check out this [wiki page](https://github.com/magdalena19/lberg-map/wiki/Application-configuration) for further information on ratMap configuration.
## **Application installation**
* Clone the repository and install gems
    ```
    git clone https://github.com/magdalena19/lberg-map.git
    cd lberg-map
    rvm install 2.3.1
    rvm use ruby-2.3.3
    rvm create gemset ratmap
    rvm gemset use ratmapp
    gem install bundler
    bundle
    ```
* Configure and export environment variables
	```
	cp sample.env .env
	vim .env
	export $(cat .env | grep -v ^# | xargs)
	```
* Create **postgresql** user with pw
	```
	sudo su postgres
	createuser <your_user> -d -W
	```
	* Allow password login in `/etc/postgresql/9.1/main/pg_hba.conf`
	```
	 local   all             all                                     md5
	```
* Create the **postgresql** database, load the db schema and precompile the assets with
	* rails setup script `bin/setup`
	* manually with rake
	```
	bundle exec rake [db:drop] db:create db:schema:load [RAILS_ENV=environment]
	bundle exec rake assets:clobber assets:precompile
	```
	* Load test points (optional) `bundle exec rake db:seed [RAILS_ENV=environment]`

* Start Redis either manually or create a dedicated service
	```
	systemctl start redis.service
	```

* Start Sidekiq `bundle exec sidekiq &`
	* The app uses [Sidekiq](https://sidekiq.org/) for background processing of machine-translations and email transport. Sidekiq will look for a running redis instance (Default: port 6379). You can start the app using . You might want to consider creating a separate service.

* Start the Unicorn rack server `bundle exec unicorn -c config/unicorn.rb`

## **Installation with docker**
A docker and docker-compose file is included in our repo to simplify to deployment.
* Clone the repository `git clone https://github.com/magdalena19/lberg-map.git`
* Configure the .env file
	```
	cp sample.env .env
	vim .env
	```
* Build the ratmap docker image `docker-compose build`
* Start the containers `docker-compose up -d`

## **Configure Nginx/SSL, Backup the database**
* [Nginx/SSL](https://github.com/magdalena19/ratMap/wiki/Nginx-SSL-Sample-Config)
* [Database Backup](https://github.com/magdalena19/ratMap/wiki/Database-Backup)

## Development
In order to **contribute** to the project you need to install the following software, otherwise testing might not work properly

  * Native binaries for [QT](https://www.qt.io/) (qt4-dev-tools, libqt4-dev, libqt4-core libqt4-gui)
  * A Javascript framework like [nodejs](https://nodejs.org/)

  Under Debian based systems (Debian, Ubuntu, etc.) you can install everything via
	```
	sudo apt-get install qt4-dev-tools libqt4-dev libqt4-core libqt4-gui nodejs
	```
