#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# During the publish phase we want to build an entirely new set of images as
# well as new JSON templates, but only if cookbooks have changed.  If any
# cookbooks have changed we trigger a build via the wrapper scripts
# wombat_build.sh and wombat_update.sh.  Once these have run successfully
# we go ahead and publish the new JSON templates to S3 for acceptance testing.

require 'aws-sdk'

# This could probably be refactored a bit
workspace = "#{workflow_workspace}/#{node['owca']['fqdn']}/default/chef-sas/bjc/master/build/publish/repo"

# Copy keys into the packer directory
execute 'copy-packer-keys' do
  command "tar -zxvf #{workflow_workspace}/Downloads/keys.tar.gz -C packer/keys --strip-components 1"
  live_stream true
  cwd workspace
  action :run
end

# Build new Chef Demo AMIs

# we're picking ubuntu runners for AWS builds
cloud = case node['platform']
        when 'ubuntu'
          'aws'
        else
          'azure'
        end

%w[build update deploy].each do |s|
  template "#{workflow_workspace}/wombat_#{s}.sh" do
    source "wombat_#{s}.sh.erb"
    mode '0755'
    variables(cloud: cloud,
              owca_fqdn: node['owca']['fqdn'])
    action :create
  end
end

execute 'build-the-things' do
  command "#{workflow_workspace}/wombat_build.sh"
  live_stream true
  cwd workspace
  action :run
end

# Create a new bjc-demo.json template
execute 'generate-json' do
  command "#{workflow_workspace}/wombat_update.sh"
  live_stream false
  cwd workspace
  action :run
end

# Use the Ruby AWS SDK to upload bjc-demo.json to S3

# Use ruby in the compile phase for testing
# s3 = Aws::S3::Resource.new(region:'us-west-2')
# obj = s3.bucket('bjcpublic').object('bjc-demo.json')
# obj.upload_file("/var/opt/delivery/workspace/#{node['owca']['fqdn']}/default/chef-sas/bjc/master/build/publish/repo/stacks/bjc-demo.json", acl:'public-read')

# And a ruby_block for executing *after* the builds are done
ruby_block "upload bjc-demo-#{cloud}.json to S3" do
  block do
    s3 = Aws::S3::Resource.new(region: 'us-west-2')
    obj = s3.bucket('bjcpublic').object("acceptance-bjc-demo-#{cloud}.json")
    obj.upload_file("#{workflow_workspace}/#{node['owca']['fqdn']}/default/chef-sas/bjc/master/build/publish/repo/stacks/bjc-demo.json", acl: 'public-read')
  end
end
