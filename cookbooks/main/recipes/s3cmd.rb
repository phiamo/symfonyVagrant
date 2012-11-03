if not File.exists?("/usr/share/s3cmd")
  remote_file "https://github.com/s3tools/s3cmd/archive/master.tar.gz" do
    source "https://github.com/s3tools/s3cmd/archive/master.tar.gz"
    path "/tmp/s3cmd.tar.gz"
  end
  
  execute "tar xzf /tmp/s3cmd.tar.gz" do
    command "tar xzf /tmp/s3cmd.tar.gz -C /usr/share"
    action :run
  end
  
  execute "mv s3cmd" do
    command "mv /usr/share/s3cmd-master /usr/share/s3cmd"
    action :run
  end
  
  execute "rm /tmp/s3cmd.tar.gz" do
    command "rm /tmp/s3cmd.tar.gz"
    action :run
  end
  
  execute "ln -s /usr/share/s3cmd/s3cmd /usr/bin/s3cmd" do
    command "ln -s /usr/share/s3cmd/s3cmd /usr/bin/s3cmd"
    action :run
  end
end

template "/etc/s3.s3cfg" do
  source "s3.s3cfg.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :access_key => node["main"]["s3cmd"]["access_key"],
    :secret_key => node["main"]["s3cmd"]["secret_key"]
  })
end