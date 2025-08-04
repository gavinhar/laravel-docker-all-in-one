# Overview

This is a clone of the Laravel 12 react starter kit with files added to build and run a docker container.
It uses a single container running php-fpm, nginx, node, and supervisord to run the backend, ssr'd frontend, and a
worker in a single container.  It is set up to read a .env file and SQLite database from outside the container.

I used ChatGPT to help put this together, it's probably not perfect and could probably be better with a multistage build
or some other tweaks, but it works.

## Build and Run

`docker compose up`

## Important Bits

If you want to copy this into your own project, these are the parts you will need:

- `Dockerfile`
- `.dockerignore`
- `docker-compose.yml`
- `docker/`
