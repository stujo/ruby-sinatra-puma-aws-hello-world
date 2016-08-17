# docker-compose Example - Sinatra + PostgreSQL

## Getting Started

*Build and Launch

    $ docker-compose -p sinatrapg build
    $ docker-compose -p sinatrapg up
    $ docker ps

*Once Only: Setup the database

    $ docker exec sinatrapg_web_1 rake db:create
    $ docker exec sinatrapg_web_1 rake db:migrate
    $ docker exec sinatrapg_web_1 rake db:seed

## Overview

What is happening?

### ``Dockerfile``

The starting docker image:

    FROM ruby:2.3

Install postgresql client package:

    RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            postgresql-client \
        && rm -rf /var/lib/apt/lists/*

Set the working directory for operations in the container

    WORKDIR /usr/src/app

Copy the Gemfile from the context (docker build directory)
and bundle install as this doesn't change very often and is 
a lot of files

    COPY Gemfile* ./
    RUN bundle install

Copy the app file from the context (docker build directory)

    COPY . .

Set environment variable for the port to use

    ENV PORT 3001

Mark the port as available for export (referenced in docker-compose.yml)

    EXPOSE 3001

The command to run (start the sever process)

    CMD ["bundle","exec","ruby","./hello-world.rb"]

Container exits when command completes



### ``docker-compose.yml``

Drives ``docker build`` commands

Describe the individual containers ``web`` and ``db`` to build

    web:

Specify which directory build

      build: .

Port ``3001`` on the container is mapped to port ``3000`` on the host

      ports:
        + "3000:3001"

Describes that this container needs network access to ``db`` container when running

      links:
        + "db"

Describe working directory for ``docker exec``

      working_dir: "/usr/src/app"  

Describe environment variables set in the container

      environment:
        + DB_HOST=db
        + DB_PORT=5432
        + DB_NAME=sinatra
        + DB_USERNAME=sinatra
        + DB_PASSWORD=sinatra

Describe the ``db`` image to build/container

    db:

There's no build just use ``postgres`` image off the shelf

      image: "postgres"

Describe environment variables set in the container

      environment:
        + POSTGRES_USER=sinatra
        + POSTGRES_PASSWORD=sinatra

Port ``5432`` on the ``db`` container is mapped to port ``5433`` on the host so we can access it if needed from the host

      ports:
        + "5433:5432"


#Deploy to Heroku

*https://devcenter.heroku.com/articles/container-registry-and-runtime

    $ heroku plugins:install heroku-container-registry

Login to the registry

    $ heroku container:login

Create a new heroku app and associate it

    $ heroku create
       Creating app... done

Build a fresh image and deploy it

    $ heroku container:push web

    $ heroku open

##How to set the DATABASE_URL?

*Add Heroku Postgres :: Database to the app on [https://dashboard.heroku.com/](https://dashboard.heroku.com/)

*Check the DATABASE_URL in the env

    $ heroku run env

*Hit the app again! - The db just works :) but we didn't migrate yet...

    $ heroku run rake db:migrate
    $ heroku run rake db:seed

##Notes on Heroku's docker container

    $ heroku run pwd
    Running pwd on ⬢ xxx... up, run.5516
    /usr/src/app

We can see that the working directory comes from the ``Dockerfile``

    $ heroku run ls -la
    Running ls -la on ⬢ xxx... up, run.7749
    total 44
    drwx------ 5 u18060 dyno 4096 Aug 17 17:36 .
    drwx------ 6 u18060 dyno 4096 Aug 17 17:36 ..
    -rw------- 1 u18060 dyno   80 Aug 17 16:26 .dockerignore
    -rw------- 1 u18060 dyno  294 Aug 16 18:55 Dockerfile
    -rw------- 1 u18060 dyno  172 Aug 17 16:22 Gemfile
    -rw------- 1 u18060 dyno  290 Aug 15 21:35 Gemfile.lock
    -rw------- 1 u18060 dyno   78 Aug 17 16:14 Rakefile
    drwx------ 2 u18060 dyno 4096 Aug 16 22:36 config
    drwx------ 3 u18060 dyno 4096 Aug 16 22:46 db
    -rw------- 1 u18060 dyno  264 Aug 16 22:57 hello-world.rb
    drwx------ 2 u18060 dyno 4096 Aug 16 22:47 models

We can see that files described in the ``.dockerignore`` file are not included in the container

