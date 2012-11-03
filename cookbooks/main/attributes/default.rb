default["main"]["hosts"] = []
default["main"]["environment"] = []

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

default["main"]["mysql"] = false
default["main"]["python"] = false
default["main"]["java"] = false
default["main"]["mongodb"] = false
default["main"]["redis"] = false
default["main"]["coffeescript"] = false
default["main"]["s3tools"] = false