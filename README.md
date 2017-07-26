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
   
  Get **[PostgreSQL](https://www.postgresql.org/)** (9.3 or a later version), the most relevant packages on a UNIX/Linux based system are `postgresql-server-dev-9.[version-no]`, `postgresql-9.[version-no]`

  The application makes use of background processing in some parts, hence it is neccessary to to install and run an instance of **[Redis](https://redis.io/)**. Install Redis under Debian/Ubuntu using `sudo apt-get install redis-server`
  
  #### **Other dependencies**
  
  * [Imagemagik](https://www.imagemagick.org/) for captcha
  
  In order to **contribute** to the project you need to install the following software, otherwise testing might not work properly
  
  * Native binaries for [QT](https://www.qt.io/) (qt4-dev-tools, libqt4-dev, libqt4-core libqt4-gui)
  * A Javascript framework like [nodejs](https://nodejs.org/)

  Under Debian based systems (Debian, Ubuntu, etc.) you can install everything via

    sudo apt-get install qt4-dev-tools libqt4-dev libqt4-core libqt4-gui nodejs imagemagick


## **Database setup**
#### **PostgreSQL**
Create a postgresql user

    sudo su postgres
    createuser <your_user> -d

_Note: For deployment you might want to `export RAILS_ENV=production` within your shell environment if you do not wish to specify the production environment for all preceding commands_

Then create the database and load the latest DB schema in development and production environment. You can either run `./bin/setup` or setup the DB manually via

    bundle exec rake [db:drop] db:create db:schema:load [RAILS_ENV=environment]
    
If you want to load some seed data do the following

    bundle exec rake db:seed [RAILS_ENV=environment]


#### **Redis**
Start Redis either manually or create a dedicated service
```
redis-server &  
```
## **Application installation**
Clone the repository and install gems

```
git clone https://github.com/magdalena19/lberg-map.git
cd lberg-map
gem install bundler
bundle
```
Test that your instance is running via `export SECRET_KEY_BASE=test123 && rails s`

#### Sidekiq
The app uses [Sidekiq](https://sidekiq.org/) for background processing of machine-translations and email transport. Sidekiq will look for a running redis instance (Default: port 6379). You can start the app using `bundle exec sidekiq &`. You might want to consider creating a separate service.

## **Application configuration**
Check out this [wiki page] for further information on ratMap configuration.
