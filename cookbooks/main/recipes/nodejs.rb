include_recipe "nodejs"
include_recipe "nodejs::npm"
 
execute "install coffeescript" do
  command "npm install -g coffee-script"
  action :run
end
execute "install zombie" do
  command "npm install -g zombie"
  action :run
end