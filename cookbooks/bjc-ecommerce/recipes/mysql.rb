#
# Cookbook Name:: bjc-ecommerce
# Recipe:: mysql
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

%w(mysql-server mysql-client).each do |p|
  package p do
    action :install
  end
end

template '/etc/mysql/my.cnf' do
  action :create
  source 'my.cnf.erb'
  notifies :restart, 'service[mysql]', :immediately
end

execute 'Update DB Permissions' do
  command "mysql -u root -e \"grant all privileges on *.* to '#{node['bjc-ecommerce']['db-user']}'@'%' identified by '#{node['bjc-ecommerce']['db-pass']}'\;\""
  action :run
  not_if "echo 'select * from information_schema.user_privileges' | mysql -u root | grep #{node['bjc-ecommerce']['db-user']}"
end

execute 'Add ecommerce database' do
  command "echo 'create database softslate' | mysql -u root"
  action :run
  not_if "echo 'show databases' | mysql -u root | grep softslate"
end

template "#{Chef::Config['file_cache_path']}/backup.sql" do
  action :create
  source 'backup.sql.erb'
  notifies :run, 'execute[restore_database_backup]', :immediately
end

execute "restore_database_backup" do
  command "mysql -u root softslate < #{Chef::Config['file_cache_path']}/backup.sql"
  action :nothing
  notifies :restart, 'service[tomcat7]', :delayed
end
