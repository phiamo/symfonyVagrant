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

template "/etc/hosts" do
  source "hosts.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :hosts => node["main"]["hosts"],
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
%w{bashrc bash_profile inputrc}.each do |filename|
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

include_recipe "build-essential"
include_recipe "main::apache"
include_recipe "main::php"

if node["main"]["mysql"] == true
  include_recipe "main::mysql"
end

gem_package "sass" do
  action :install
end

if node["main"]["python"] == true
  include_recipe "python"
end

if node["main"]["java"] == true
  include_recipe "java"
end

if node["main"]["mongodb"] == true
  include_recipe "main::mongodb"
end

if node["main"]["redis"] == true
  include_recipe "main::redis"
end

if node["main"]["coffeescript"] == true
  include_recipe "main::nodejs"
end

if node["main"]["s3tools"] == true
  include_recipe "main::s3cmd"
end

# Buildscripts
node["main"]["buildscript"].each do |buildCommand|
  execute "buildscript" do
    user "root"
    command buildCommand
    action :run
  end
end
