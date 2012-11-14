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