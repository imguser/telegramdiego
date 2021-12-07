# README

## Build & run project
docker-compose up --build

## Run project
docker-compose up

## Create database
docker-compose exec app bundle exec rake db:setup db:migrate