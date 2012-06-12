default["main"]["apache2"]["vhost"] = []

default["main"]["php"]["apache_conf_dir"]  = "/etc/php5/apache2"

default["main"]["database"] = []

default["main"]["dbuser"] = [{
    "name" => "root",
    "password" => "root",
    "host" => "%",
    "privileges" => [:all]
  }]

default["main"]["buildscript"] = []

default["main"]["redis"] = true