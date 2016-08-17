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

