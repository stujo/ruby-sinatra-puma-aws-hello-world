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

*Silently we are still running in development mode, let's fix that

    $ heroku config:set RACK_ENV=production

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

After making a change...(not necessary to commit to git)

    $  heroku container:push web
    Sending build context to Docker daemon 16.38 kB
    Step 1 : FROM ruby:2.3
     ---> 7b66156f376c
    Step 2 : RUN apt-get update     && apt-get install -y --no-install-recommends         postgresql-client     && rm -rf /var/lib/apt/lists/*
     ---> Using cache
     ---> 5cc2ae864742
    Step 3 : WORKDIR /usr/src/app
     ---> Using cache
     ---> 5e8a9bcb238b
    Step 4 : COPY Gemfile* ./
     ---> Using cache
     ---> 02c7bba9f598
    Step 5 : RUN bundle install
     ---> Using cache
     ---> c1ab49364ab9
    Step 6 : COPY . .
     ---> 0bfeafa8026a
    Removing intermediate container a21712024040
    Step 7 : ENV PORT 3001
     ---> Running in 1b15d4e860db
     ---> 51033826d191
    Removing intermediate container 1b15d4e860db
    Step 8 : EXPOSE 3001
     ---> Running in b14fbcad3cf8
     ---> 6ad0d158c65b
    Removing intermediate container b14fbcad3cf8
    Step 9 : CMD bundle exec ruby ./hello-world.rb
     ---> Running in f1553e0bb570
     ---> d2d6e68b506d
    Removing intermediate container f1553e0bb570
    Successfully built d2d6e68b506d
    The push refers to a repository [registry.heroku.com/still-spire-19030/web]
    565239e8f490: Pushed 
    a536f84c0570: Layer already exists 
    9c741df14b2e: Layer already exists 
    7350f218af3d: Layer already exists 
    4e827c9eb3cf: Layer already exists 
    0d545b132edd: Layer already exists 
    8c3a5fd135d0: Layer already exists 
    59f45a5d2272: Layer already exists 
    e636ba91df19: Layer already exists 
    04dc8c446a38: Layer already exists 
    1050aff7cfff: Layer already exists 
    66d8e5ee400c: Layer already exists 
    2f71b45e4e25: Layer already exists 
    latest: digest: sha256:8ed92e71b6dfbc9640664b6a01b068cf6a896f1dc2e39bf7af26d263ad914dda size: 3047

Port mapping is still a mystery to me

*Our ``Dockerfile`` defaults ``PORT=3001``
*Heroku's env sets ``PORT=56522``
*Our log files say ``Sinatra 0.0.0.0 54689``

It may be that the port is dynamic? 


 


