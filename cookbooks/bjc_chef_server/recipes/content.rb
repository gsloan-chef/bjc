#
# Cookbook Name:: bjc_chef_server
# Recipe:: cheffish
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

home = Dir.home

package 'unzip'
package 'git'
include_recipe 'build-essential'

%w[.chef cookbooks roles].each do |structure|
  directory "#{home}/#{structure}"
end

file "#{home}/.chef/config.rb" do
  content <<-EOS
  chef_server_url "https://127.0.0.1/organizations/#{node['demo']['org']}"
  client_key '/etc/opscode/pivotal.pem'
  node_name 'pivotal'
  cookbook_path ["#{home}/cookbooks"]
  ssl_verify_mode :verify_none
  EOS
end

git "#{Chef::Config[:file_cache_path]}/bjc" do
  repository 'https://github.com/chef-cft/bjc'
  revision 'master'
  action :sync
end

node['bjc_chef_server']['cookbooks'].each do |cookbook|
  execute "berks install #{cookbook}" do
    cwd "#{Chef::Config[:file_cache_path]}/bjc/cookbooks/#{cookbook}"
    command '/opt/opscode/embedded/bin/berks install'
    action :run
  end

  execute "berks upload #{cookbook}" do
    cwd "#{Chef::Config[:file_cache_path]}/bjc/cookbooks/#{cookbook}"
    command '/opt/opscode/embedded/bin/berks upload --no-ssl-verify'
    action :run
  end
end
