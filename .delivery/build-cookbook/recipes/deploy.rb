
# Cookbook Name:: build-cookbook
# Recipe:: deploy
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# This multi-function recipe has different purposes depending on what stage
# it gets run it.  During acceptance it will stand up an demo using the current
# acceptance-bjc-demo Cloudformation template.  During the Delivered stage it
# will instead publish the latest JSON template to S3 with a version number.
# When new demos are published an AWS lambda function announces the new demo
# in the #chef-demo-project slack channel.

require 'json'
require 'aws-sdk'
include_recipe 'chef-sugar::default'

# we're picking ubuntu runners for AWS builds
case node['platform']
when 'ubuntu'
  cloud = 'aws'
else
  cloud = 'azure'
end

# This part runs only in 'Acceptance'.  Stand up a demo for testing.
if ['acceptance'].include?(node['delivery']['change']['stage'])
  workspace = "#{workflow_workspace}/#{node['owca']['fqdn']}/default/chef-sas/bjc/master/acceptance/deploy/repo"
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

  %w(deploy).each do |s|
    template "#{workflow_workspace}/wombat_#{s}.sh" do
      source "wombat_#{s}.sh.erb"
      mode '0755'
      variables(:cloud => cloud)
      action :create
    end
  end
  # Use this wrapper script to stand up the demo.
  execute "Deploy Acceptance Stack in #{cloud}" do
    command "#{workflow_workspace}/wombat_deploy.sh"
    cwd workspace
    # Disabled because it crashes Automate
    #live_stream true
    action :run
  end
end

# This part only runs in 'Delivered'. Publish the new json to S3.
if ['delivered'].include?(node['delivery']['change']['stage'])

  workspace = "#{workflow_workspace}/#{node['owca']['fqdn']}/default/chef-sas/bjc/master/delivered/deploy/repo"

  remote_file "#{workspace}/stacks/acceptance-bjc-demo-#{cloud}.json" do
    action :create
    source "https://s3-us-west-2.amazonaws.com/bjcpublic/acceptance-bjc-demo-#{cloud}.json"
  end

  ruby_block "Publish acceptance-bjc-demo-#{cloud}.json to S3" do
    block do
      cfjson = File.read("#{workspace}/stacks/acceptance-bjc-demo-#{cloud}.json")
      data_hash = JSON.parse(cfjson)
      if cloud == 'aws'
        version = data_hash['Parameters']['Version']['Default']
      elsif cloud =='azure'
        version = data_hash['contentVersion']
      end
      s3 = Aws::S3::Resource.new(region:'us-west-2')
      obj = s3.bucket('bjcpublic').object("cloudformation/bjc-demo-#{cloud}-#{version}.json")
      unless obj.exists?
        obj.upload_file("#{workspace}/stacks/acceptance-bjc-demo-#{cloud}.json", acl:'public-read')
      end
    end
  end

  # Publish the demo to all the accounts listed in accounts.json
  accounts = File.read("#{workspace}/accounts.json")
  acct_hash = JSON.parse(accounts)
  acct_hash['accounts'].each do |acct|
    execute "Export BJC demo to other AWS accounts." do
      command "#{workspace}/bin/publish_demo_to_account.sh #{workspace}/stacks/acceptance-bjc-demo-aws.json #{acct}"
    end
  end
end
