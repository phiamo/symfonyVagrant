# Run apt-get update before the chef convergence stage
r = execute "apt-get update" do
  user "root"
  command "apt-get update"
  action :nothing
end
r.run_action(:run)

gem_package "chef" do
  action :upgrade
end

# Install normal apt-get packages
%w{vim man-db git-core ruby-dev tofrodos}.each do |pkg|
  package pkg do
    action :install
  end
end

include_recipe "apt"

template "/etc/environment" do
  source "environment.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :environment => node["main"]["environment"],
  })
end

apt_repository "php54" do
  uri "http://ppa.launchpad.net/ondrej/php5/ubuntu"
  distribution "lucid"
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "E5267A6C"
  action :add
  notifies :run, "execute[apt-get update]", :immediately
  deb_src true
end

# bash profile
%w{bashrc bash_profile}.each do |filename|
  template "/home/vagrant/." + filename do
    source filename + ".erb"
    owner "vagrant"
    group "vagrant"
    mode "0644"
  end
end

# hiding login message
execute "touch /home/vagrant/.hushlogin" do
  command "touch /home/vagrant/.hushlogin"
  action :run
end

# Change timezone
template "/etc/timezone" do
  source "timezone.erb"
  owner "root"
  group "root"
  mode "0644"
end
execute " sudo dpkg-reconfigure --frontend noninteractive tzdata" do
  command " sudo dpkg-reconfigure --frontend noninteractive tzdata"
  action :run
end

# build-essential
include_recipe "build-essential"

# Apache2
include_recipe "apache2"
include_recipe "apache2::mod_php5"

node["main"]["apache2"]["vhost"].each do |vhost|
  web_app vhost["name"] do
    app_name vhost["name"]
    server_name vhost["server_name"]
    docroot vhost["docroot"]
    dirindex vhost["dirindex"]
    template vhost["template"]
  end
end
execute "disable-default-site" do
  command "sudo a2dissite default"
  notifies :restart, resources(:service => "apache2"), :delayed
end

# PHP5
include_recipe "php"
include_recipe "php::module_mysql"

[node["main"]["php"]["apache_conf_dir"], node["php"]["conf_dir"]].each do |dir|
  template "#{dir}/php.ini" do
    source "php.ini.erb"
    owner "root"
    group "root"
    mode "0644"
  end
end

# Supporting packages
%w{php5-intl php-apc php5-gd php5-xdebug}.each do |pkg|
  package pkg do
    action :install
    notifies :reload, resources(:service => "apache2"), :delayed
  end
end

# Mysql and Databases
if node["main"]["mysql"] == true
  include_recipe "mysql"
  include_recipe "mysql::server"
  template "/etc/mysql/my.cnf" do
    source "my.cnf.erb"
    owner "root"
    group "root"
    mode "0644"
  end

  gem_package "mysql" do
    action :install
  end

  # Databases
  include_recipe "database"
  mysql_connection_info = {:host => "localhost", :username => "root", :password => node["mysql"]["server_root_password"]}

  node["main"]["database"].each do |dbname|
    mysql_database dbname do
      connection mysql_connection_info
      action :create
    end
  end
  node["main"]["dbuser"].each do |user|
    mysql_database_user user["name"] do
      connection mysql_connection_info
      password user["password"]
      host user["host"]
      database_name user["database_name"]
      privileges user["privileges"]
      action :create
      action :grant
    end
  end
end

# Sass
gem_package "sass" do
  action :install
end

# Python
if node["main"]["python"] == true
  include_recipe "python"
end

# Java
if node["main"]["java"] == true
  include_recipe "java"
end

# MongoDB
if node["main"]["mongodb"] == true
  include_recipe "mongodb::10gen_repo"
  include_recipe "mongodb::default"
  template "/etc/mongodb.conf" do
    source "mongodb.conf.erb"
    owner "root"
    group "root"
    mode "0644"
  end
  execute "install php-mongodb" do
    user "root"
    command "pecl install -f mongo"
    action :run
  end
  execute "restart mongodb" do
    user "root"
    command "/etc/init.d/mongodb restart"
    action :run
  end
end

# redis.io
if node["main"]["redis"] == true
  include_recipe "redisio::install"
  include_recipe "redisio::enable"
end

# node.js
if node["main"]["coffeescript"] == true
  include_recipe "nodejs"
  include_recipe "nodejs::npm"
  
  execute "install coffeescript" do
    command "npm install -g coffee-script"
    action :run
    not_if "which coffee"
  end
end

# s3tools
if node["main"]["s3tools"] == true
  include_recipe "main::s3cmd"
end

# Buildscripts
if not File.exists?("/home/vagrant/installed")
  node["main"]["buildscript"].each do |buildCommand|
    execute "buildscript" do
      user "root"
      command buildCommand
      action :run
    end
  end
  
  execute "touch installed" do
    user "vagrant"
    command "touch /home/vagrant/installed"
    action :run
  end
end
