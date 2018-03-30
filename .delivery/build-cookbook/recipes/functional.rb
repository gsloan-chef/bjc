#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

stack_region = 'us-west-2'
stack_name = 'acceptance-bjc-demo'

if ['acceptance'].include?(node['delivery']['change']['stage'])
  ruby_block 'Waiting for Acceptance stack to be ready...' do
    block do
      sleep 120
    end
  end

  automate_ip = get_public_ip(stack_region, stack_name, 'Automate')

  delivery_inspec automate_ip.to_s do
    infra_node automate_ip.to_s
    inspec_test_path '/cookbooks/bjc_automate/test/integration/default'
    os 'linux'
  end

  chef_ip = get_public_ip(stack_region, stack_name, 'Chef')

  delivery_inspec chef_ip.to_s do
    infra_node chef_ip.to_s
    inspec_test_path '/cookbooks/bjc_chef_server/test/integration/default'
    os 'linux'
  end

  windows_ip = get_public_ip(stack_region, stack_name, 'WindowsWorkstation1')

  delivery_inspec windows_ip.to_s do
    infra_node windows_ip.to_s
    inspec_test_path '/cookbooks/bjc_workstation/test/integration/default'
    os 'windows'
  end
end
