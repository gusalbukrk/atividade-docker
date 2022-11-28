#!/bin/bash

if [[ $# != 2 ]]; then
  echo "ERROR: Script must receive exactly 2 arguments — root password & wordpress database administrator password."
  exit 1
fi

docker network create wp-network;

docker build --tag db \
  -f Dockerfile.db \
  .;

docker build --tag wp \
  -f Dockerfile.wp \
  .;

docker run -d --name db \
  --env MYSQL_ROOT_PASSWORD=$1 \
  --env MYSQL_PASSWORD=$2 \
  --network wp-network \
  --volume db-data:/var/lib/mysql \
  -p 3306:3306 \
  db

docker run -d --name wp \
  --env WORDPRESS_DB_PASSWORD=$2 \
  --network wp-network \
  --volume wp-data:/var/www/html \
  -p 80:80 \
  wp;

docker run -d --name admin \
  --network wp-network \
  --link db:db \
  -p 82:80 \
  phpmyadmin:5.2.0;
