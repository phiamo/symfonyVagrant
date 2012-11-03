This project contains all cookbooks and configuration needed for a clean setup of vagrant and chef
to use symfony2 inside the virtual machine

Sgoettschkes/symfonyVagrant
===========================

This cookbooks aim to set up a out of the box working server to develop symfony2 applications. It 
uses the following cookbooks authored by the guys at opscode (for more information see below):

* apache2
* build-essential
* database
* java
* mysql
* nodejs
* openssl
* php
* python
* redisio

The glue which holds them together and executes everything is the main cookbook. The config from
the vagrant file is read and put into place. It distributes it's own php.ini and apache vhost
template as needed.

Install and boot vagrant basebox
--------------------------------

1. Install virtualbox: http://www.virtualbox.org
2. Install vagrant: http://www.vagrantup.com
3. `cd /path/to/symfonyVagrant`
4. `cp Vagrantfile.dist Vagrantfile`
6. `vagrant up`
7. Wait (You can get a cup of coffee, this will take some time)

Change the Vagrantfile according to your needs.

Software avaiable
-----------------

Vagrant installes a 64-bit Ubuntu Server in version 10.04 with SSL setup. It also takes care of mounting the
shared folders. Ruby is already installed.

Chef installes the following software:

* apache2 (including virtualhosts file)
* php5
* mysql (including database setup) (optional)
* sass (Ruby gem)
* python (optional)
* java (optional)
* mongodb (optional)
* redis (optional)
* node.js & coffeescript (optional)
* [s3cmd tools](https://github.com/s3tools/s3cmd) (optional)

It also executes any build script which can be defined as a command executed on command line, so you can use
php, python, java (ant e.g.) or any other build script which can be executed through command line.

You need to add the vhost server_name to your hosts file using the ip specified in the Vagrantfile.

License and Author
==================

The cookbooks used by the main cookbook can be found here: https://github.com/opscode-cookbooks/

The main cookbook was created by

Author:: Sebastian Goettschkes (<sebastian.goettschkes@boosolution.de>)

Copyright 2012, boosolution Sebastian Goettschkes

All cookbooks except for the main were created by various people from opscode or others. Please
take care to give back something if you find this work valuable. You could for example open source your
own code if it adds value to the vagrant or chef projects.