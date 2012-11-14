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