#!/usr/bin/env ruby
require 'pathname'

desc 'Reset DB'
task reset_db: :environment do
  APP_ROOT = Pathname.new File.expand_path('../../',  __FILE__)

  Dir.chdir APP_ROOT do
    system 'bundle exec rake db:reset'
  end
end
