#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# How does this work?  The bjc_compliance default recipe contains a resource
# to clone the BJC git repo (so we can get all the inspec profiles).  Once
# all the inspec profiles for the BJC components are on the compliance
# server, we can run remote scans against a stack by ssh-ing into the
# compliance box and kicking off `inspec exec` commands.  The wrapper script
# shown below contains the commands to run inspec against our machines.


# Run inspec tests on the machines in our environment
if ['acceptance'].include?(node['delivery']['change']['stage'])
  ruby_block 'Waiting for Acceptance stack to be ready...' do
    block do
      sleep 120
    end
  end
  execute 'Run inspec tests' do
    command "#{workflow_workspace}/inspec_tests.sh"
    cwd workflow_workspace
    live_stream true
    action :run
  end
end
