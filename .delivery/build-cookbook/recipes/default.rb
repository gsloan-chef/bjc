#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

if node['platform'] == 'ubuntu'
  apt_update 'update ubuntu packages' do
    action :update
  end
end

if node['platform'] == 'centos'
  yum_repository 'epel' do
    description 'Extra Packages for Enterprise Linux 7 - x86_64'
    mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-7&arch=x86_64'
    gpgkey 'http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7'
    action :create
  end
end

node.default['build-essential']['compile_time'] = true
include_recipe 'build-essential::default'

node.default['packer']['version'] = '1.1.0'
include_recipe 'sbp_packer'

chef_gem 'wombat-cli' do
  version '0.6.2' 
end

chef_gem 'aws-sdk'

chef_gem 'net-ssh' do
  version '3.2.0'
end

chef_gem 'rake' do
  version '11.2.0'
end

chef_gem 'http-cookie' do
  version '1.0.0'
end

template "#{workflow_workspace}/inspec_tests.sh" do
  action :create
  source 'inspec_tests.sh.erb'
  mode '0755'
end

package 'awscli'

if node['platform'] == 'ubuntu'
  package 'jq'
elsif node['platform'] == 'centos'
  # This is horrible, but EPELs release of jq is 1.3 for CentOS 6
  remote_file '/usr/local/bin/jq' do
    source 'https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64'
    checksum 'c6b3a7d7d3e7b70c6f51b706a3b90bd01833846c54d32ca32f0027f00226ff6d'
    action :create_if_missing
    mode '0755'
  end
end
