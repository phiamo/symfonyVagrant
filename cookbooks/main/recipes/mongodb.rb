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
  command "pecl install -f mongo-1.2.9"
  action :run
end
execute "restart mongodb" do
  user "root"
  command "/etc/init.d/mongodb restart"
  action :run
end