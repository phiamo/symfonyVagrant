# Run apt-get update before the chef convergence stage
r = execute "apt-get update" do
  user "root"
  command "apt-get update"
  action :nothing
end
r.run_action(:run)

template "/etc/apt/sources.list" do
  source "sources.list.erb"
  owner "root"
  group "root"
  mode "0644"
end
execute "new apt-key" do
  command "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C"
  action :run
end
execute "apt-get update" do
  user "root"
  command "apt-get update"
  action :run
end

# Install normal apt-get packages
%w{vim man-db git-core ruby-dev php5-sqlite tofrodos}.each do |pkg|
  package pkg do
    action :install
  end
end

template "/etc/environment" do
  source "environment.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :environment => node["main"]["environment"],
  })
end

template "/etc/hosts" do
  source "hosts.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :hosts => node["main"]["hosts"],
  })
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
require_recipe "build-essential"

# Apache2
require_recipe "apache2"
require_recipe "apache2::mod_php5"

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
require_recipe "php"
require_recipe "php::module_mysql"

[node["main"]["php"]["apache_conf_dir"], node["php"]["conf_dir"]].each do |dir|
  template "#{dir}/php.ini" do
    source "php.ini.erb"
    owner "root"
    group "root"
    mode "0644"
  end
end

# Supporting packages
package "php5-intl" do
  action :install
  notifies :restart, resources(:service => "apache2"), :delayed
end
package "php-apc" do
  action :install
  notifies :restart, resources(:service => "apache2"), :delayed
end
package "php5-xdebug" do
  action :install
end

# PEAR/PECL
php_pear "pear" do
  action :upgrade
end
%w{pear.symfony-project.com pear.phpunit.de components.ez.no pear.phing.info}.each do |channel|
  php_pear_channel channel do
    action :discover
  end
end

# PHP Packages using PEAR and PECL
execute "install phing" do
  user "root"
  command "pear install phing/phing"
  action :run
  not_if "which phing"
end
execute "install phpunit" do
  user "root"
  command "pear install --alldeps phpunit/PHPUnit"
  action :run
  not_if "which phpunit"
end
execute "install PHP_CodeSniffer" do
  user "root"
  command "pear install --alldeps PHP_CodeSniffer"
  action :run
  not_if "which phpcs"
end

# Mysql
require_recipe "mysql"
require_recipe "mysql::server"
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
require_recipe "database"
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

# Sass
gem_package "sass" do
  action :install
end

# Python
require_recipe "python"

# Java
require_recipe "java"

# MongoDB
require_recipe "mongodb::default" 
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

# redis.io
if node["main"]["redis"] == true
  require_recipe "redisio::install"
  require_recipe "redisio::enable"
end

# node.js
if node["main"]["coffeescript"] == true
  require_recipe "nodejs"
  require_recipe "nodejs::npm"
  
  execute "install coffeescript" do
    command "npm install -g coffee-script"
    action :run
    not_if "which coffee"
  end
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
