#!/bin/bash

case $1 in
  start)

    supervisord -c /lbergmap/supervisord.conf -n
  ;;
  migrate)
    cd /lbergmap   
    bundle install --deployment --quiet
    [ -f /data/config/database.yml ] && bundle exec rake db:migrate

    bundle exec rake assets:precompile
  ;;  
  *)
    echo Commands:
    echo "    start       Launch the complete package"
    echo "    migrate     runs db migrate, asset precompile"
  ;;
esac

wait
