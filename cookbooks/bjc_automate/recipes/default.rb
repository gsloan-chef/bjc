#
# Cookbook Name:: bjc_automate
# Recipe:: default
#
# Copyright (c) 2016 The Authors, Al Rights Reserved.

automate_archive = "#{Chef::Config[:file_cache_path]}/chef-automate_linux_amd64.zip"
automate_license = "#{Chef::Config[:file_cache_path]}/automate.license"

apt_update 'packages' do
  action :update
  only_if { node['platform_family'] == 'debian' }
end

append_if_no_line "Add temporary hostsfile entry: #{node['ipaddress']}" do
  path "/etc/hosts"
  line "#{node['ipaddress']} #{node['demo']['automate_fqdn']} automate"
end

execute 'hostnamectl set-hostname automate'

package 'jq'

sysctl 'vm.max_map_count' do
  value 262144
end

sysctl 'vm.dirty_expire_centisecs' do
  value 20000
end

package 'zip'

template "#{Chef::Config[:file_cache_path]}/config.toml" do
  source 'automate-config.toml.erb'
  variables(fqdn: 'automate.automate-demo.com')
  sensitive true
end

remote_file automate_archive do
  source 'https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip'
end

execute 'Extract Automate' do
  command "unzip #{automate_archive} -d /usr/sbin"
  not_if { ::File.exist?('/usr/local/bin/chef-automate') }
end

# NOTE:  This command will fail if run a second time
#        This is OK for now as the intent is to build images for
#        deployement in a demo environment and typically this won't
#        be run multiple times.
execute 'Deploy Automate' do
  command 'chef-automate deploy config.toml  --accept-terms-and-mlsa'
  cwd Chef::Config[:file_cache_path]
end

file automate_license do
  content lazy { IO.read('/tmp/delivery.license') }
  action :create
  sensitive true
end

execute 'Apply license' do
  command "chef-automate license apply $(cat #{automate_license})"
end

file automate_license do
  action :delete
end

template '/root/add_users.sh' do
  source 'add_users.sh.erb'
  mode 0755
  variables (
    lazy {
      { token: shell_out("chef-automate admin-token").stdout.strip }
    }
  )
  notifies :run, 'execute[addusers]', :immediately
end

execute 'addusers' do
  command "sh /root/add_users.sh"
  live_stream true
  action :nothing
end

include_recipe 'wombat::authorized-keys'
