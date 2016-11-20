# Howto Deploy new Version
* go to /ruby-webapps
* login as user lpkb    `sudo su lpkb`
* check name container	`docker ps`
* dump database			` docker exec -t lbergmap_containername  pg_dumpall -c -U postgres > ~/dump_beforeDeployment.sql`
* stop docker container `docker-compose stop`
* pull git              `git pull`

* rebuild image         `docker-compose build`
* migrate db            `docker-compose run -T lbergmap rake db:migrate` better rake db:schema:load
* delete old assets     `docker-compose run -T lbergmap rake assets:clobber`
* precompile assets     `docker-compose run -T lbergmap rake assets:precompile`
* start docker image    `docker-compose up -d`
