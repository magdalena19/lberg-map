# **RatMap**

**A Ruby on Rails 4 application for collaboratively mapping and sharing points of interest on a website**

  
  [![Build Status](https://travis-ci.org/magdalena19/lberg-map.svg?branch=master)](https://travis-ci.org/magdalena19/lberg-map)
  [![Code Climate](https://codeclimate.com/github/magdalena19/lberg-map/badges/gpa.svg)](https://codeclimate.com/github/magdalena19/lberg-map)
  [![Test Coverage](https://codeclimate.com/github/magdalena19/lberg-map/badges/coverage.svg)](https://codeclimate.com/github/magdalena19/lberg-map/coverage)

## **Features**
---

* **Individual maps**: Create _public_, _semi-public_ or _private maps_ as a registered user or guest
* **Share maps**: Invite others to see what you've contributed or embed your map on other websites
* **Reviewing contributions**: Let guests contribute POIs on public maps and either accept or revert their entries as map admin
* **Multi-language support**: Optionally machine-translate to other languages supported by the system (so far english and german)

Check out the **[Demo](https://korner.lynx.uberspace.de)** either as
* guest 
* user (_user@test.com / secret_)

_=> Passwords for the user account as well as the demo password-protected map is 'secret'_
  
## **System prerequisits**
---
  
  #### **Ruby**
  
  This application was written and tested under Ruby version 2.3.1. Installation via RVM recommended.

  _Note: Ruby 2.4* will not work!_
  
  #### **Databases**
   
  Get **[PostgreSQL](https://www.postgresql.org/)** (9.3 or a later version), the most relevant packages on a UNIX/Linux based system are `postgresql-server-dev-9.[version-no]`, `postgresql-9.[version-no]`

  The application makes use of background processing in some parts, hence it is neccessary to to install and run an instance of **[Redis](https://redis.io/)**.
  
  #### **Other dependencies**
  
  * [Imagemagik](https://www.imagemagick.org/) for captcha
  
  In order to **contribute** to the project you need to install the following software, otherwise testing might not work properly
  
  * Native binaries for [QT](https://www.qt.io/) (qt4-dev-tools, libqt4-dev, libqt4-core libqt4-gui)
  
  * A Javascript framework like [nodejs](https://nodejs.org/)
 
  
   
  Under Debian based systems (Debian, Ubuntu, etc.) you can install everything via

    sudo apt-get install qt4-dev-tools libqt4-dev libqt4-core libqt4-gui nodejs imagemagick
   

## **Application installation**
---

Clone the repository and install gems

```
git clone https://github.com/magdalena19/lberg-map.git
cd lberg-map
gem install bundler
bundle
```

## **Database setup**
---


#### **PostgreSQL**
Create a postgresql user

    sudo su postgres
    createuser <your_user> -d
   
Then create the database and load the latest DB schema in development and production environment.

_Note: For deployment you might want to `export RAILS_ENV=production` within your shell environment if you do not wish to specify the production environment for all preceding commands_

    bundle exec rake db:create db:schema:load && bundle exec rake db:create db:schema:load RAILS_ENV=[environment]
    
If you want to load some seed data do the following

    bundle exec rake db:seed RAILS_ENV=[environment]


#### **Redis**
Start Redis either manually or create a dedicated service
```
redis-server &  
```

## **Application configuration**
---


#### **Environment variables**
All kinds of API keys, tokens, etc. used within the application need to be inserted into `config/application.yml` which has the following structure

```
production:
  # Email relay services
  relay_address: ...
  relay_login: ...
  ...
```

Environment variables are managed by a Ruby Gem called [Figaro](https://github.com/laserlemon/figaro), which offers some benefits compared to the use of rails own `secrets.yml`-approach.

#### **Application secret key**

It is imperative not to forget to generate a secret token used to sign / encrypt session cookies used in this application via (Rails 4)

    rake secret

The generated token has to be inserted into
`config/application.yml` under 

```
production:
  ...
  
  # Secret key base
  SECRET_KEY_BASE: <KEY>
```

####  **Captcha configuration**
The application uses [Recaptcha](https://github.com/ambethia/recaptcha) and [simple_captcha](https://github.com/galetahub/simple-captcha) as form protection systems. Site admins can choose between both via the admin interface and need to supply valid tokens.

```
production:
  ...
  
  # Captcha
  RECAPTCHA_SITE_KEY: <KEY>
  RECAPTCHA_SECRET_KEY: <KEY>
  captcha_secret: <KEY>
```
  
The one for **simple_captcha** has to be generated manually via `rake secret`. _ImageMagick should be installed on your machine to use this plugin!_

In order to use **recaptcha** you have to [sign up at Google]() and get an API key pair there.

#### **Machine translation APIs**
The application makes use of different machine translation APIs, which all need custom keys. Place these under

```
production:
  ...
  
  # Machine translation APIs
  bing_id: <KEY>
  bing_secret: <KEY>
  microsoft_account_key: <KEY>
  yandex_secret: <KEY>
```

#### **Mail relaying**
Setup mail relaying related information here
```
production:
  ...
  
  # Email relay services
  relay_address: ...
  relay_login: ...
  relay_port: "587"
  relay_passwd: <KEY>
  relay_auth: plain
```

#### **PostgreSQL**
Your DB setup also needs to be configured via environment variables. If you're not running the application within a containerized setup put the following information inside `config/application.yml`

```
production:
  ...
  
  # Postgres
  POSTGRES_HOST: <KEY>
  POSTGRES_USER: <KEY>
  POSTGRES_PASSWORD: <KEY>

```
