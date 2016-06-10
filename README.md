***Local Development Environment***

Some Dependencies you need:

    clone the repository

    get the common ruby version e.g. 2.3 at the moment (installation via RVM recommended or according to this post: ryanbigg.com/2014/10/ubuntu-ruby-ruby-install-chruby-and-you// )

    get PostgreSQL 9.3 or a later version(and postgresql-server-dev-9.3), QT libs (qt4-dev-tools libqt4-dev libqt4-core libqt4-gui)  

Inside the project folder run:

```
sudo gem install bundler

bundle install

create postgresql user -> sudo su postgres; createuser <your_system_user> -d

createdb lberg-map_development

bin/rake db:migrate RAILS_ENV=development
```

Start the App with

`rails s`

You can access the site in the browser with 127.0.0.1:3000

or

`localhost:3000`
