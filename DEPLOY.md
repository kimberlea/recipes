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

Extras
======

Update Bashrc with S3 and Rails env vars

