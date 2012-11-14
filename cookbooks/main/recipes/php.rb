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

# curl for php
%w{libcurl3 libcurl3-dev php5-curl}.each do |pkg|
  package pkg do
    action :install
  end
end