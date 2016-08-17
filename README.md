# docker-compose Example - Sinatra + PostgreSQL

Instructions:

## Build and Launch

$ docker-compose -p sinatrapg build

$ docker-compose -p sinatrapg up

$ docker ps

## Once Only to setup the database

$ docker exec sinatrapg_web_1 rake db:create

$ docker exec  sinatrapg_web_1 rake db:migrate

$ docker exec  sinatrapg_web_1 rake db:seed

