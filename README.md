[![Build Status](https://travis-ci.org/magdalena19/lberg-map.svg?branch=master)](https://travis-ci.org/magdalena19/lberg-map)

***Local Development Environment***

Some Dependencies you need:

    clone the repository

    get the common ruby version e.g. 2.1 at the moment (installation via RVM recommended or according to this post: ryanbigg.com/2014/10/ubuntu-ruby-ruby-install-chruby-and-you// )

    get PostgreSQL 9.3 or a later version and libpq-dev

    install nodejs

Inside the project folder run:

```
sudo gem install bundler

bundle install

createdb lberg-map_development

bin/rake db:migrate RAILS_ENV=development
```

Start the App with

`rails s`

You can access the site in the browser with 127.0.0.1:3000

or

`localhost:3000`

***Dev admin access***

You can enter the admin area with the credentials:
User: admin
pass: secret

