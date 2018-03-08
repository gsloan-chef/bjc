#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'aws-sdk'

case node['platform']
when 'ubuntu'
  cloud = 'aws'
else
  cloud = 'azure'
end

# Only run in the Union phase
if ['union'].include?(node['delivery']['change']['stage'])
  workspace = "#{workflow_workspace}/#{node['owca']['fqdn']}/default/chef-sas/bjc/master/union/provision/repo"
  # Copy keys into the packer directory.  Not sure this is necessary here.
  execute "copy-packer-keys" do
    command "tar -zxvf #{workflow_workspace}/Downloads/keys.tar.gz -C packer/keys --strip-components 1"
    # Disabled because it crashes Automate
    # live_stream true
    cwd workspace
    action :run
  end

  # Fetch the bjc-demo.json that was created in the last successful build
  remote_file "#{workspace}/stacks/bjc-demo.json" do
    source "https://s3-us-west-2.amazonaws.com/bjcpublic/acceptance-bjc-demo-#{cloud}.json"
    action :create
  end

  %w(delete).each do |s|
    template "#{workflow_workspace}/wombat_#{s}.sh" do
      source "wombat_#{s}.sh.erb"
      mode '0755'
      variables(:cloud => cloud)
      action :create
    end
  end
  # Use this wrapper script to stand up the demo.
  execute "Delete Acceptance Stack in #{cloud}" do
    command "#{workflow_workspace}/wombat_delete.sh"
    cwd workspace
    # Disabled because it crashes Automate
    #live_stream true
    action :run
  end
end
