Packages
========

> sudo apt-get install libpq-dev imagemagick libmagickcore-dev libmagickwand-dev g++

RVM
====

Install RVM

Install Ruby 2.2.5

PostgreSQL
===========

> sudo vim /etc/apt/sources.list.d/pgdg.list

# PostgreSQL repository
deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main

> wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

> sudo apt-get update

> sudo apt-get install postgresql-9.5

# add user

> sudo su - postgres
> psql
> CREATE USER kimberlea WITH CREATEDB PASSWORD 'pancakes';

Nginx
=====

> sudo apt-get install nginx


MongoDB
=======

> docker run --name mongo -v mongodata1:/data/db -p 27017:27017 -d mongo:2.6.12

ElasticSearch
=============

# development
> sudo docker run --name elastic -v esdata1:/usr/share/elasticsearch/data -p 9200:9200 -e "discovery.type=single-node" -e "xpack.security.enabled=false" -e "ES_JAVA_OPTS=-Xms128m -Xmx128m" -d docker.elastic.co/elasticsearch/elasticsearch:5.6.2

# production
> sudo docker run --name elastic -v esdata1:/usr/share/elasticsearch/data -p 9200:9200 -e "discovery.type=single-node" -e "xpack.security.enabled=false" -e "ES_JAVA_OPTS=-Xms4g -Xmx4g" -d docker.elastic.co/elasticsearch/elasticsearch:5.6.2

Extras
======

Update Bashrc with S3 and Rails env vars

