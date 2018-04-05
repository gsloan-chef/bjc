#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

raise 'You must update CHANGELOG.md before your change can be promoted!' if !changed_files.include?("CHANGELOG.md")

change_demo_ver = YAML.load_file("#{workflow_workspace_repo}/wombat.yml")['version']
master_wombat_yml = shell_out!('git show master/wombat.yml', cwd: workflow_workspace_repo)
master_demo_ver = YAML.load_file(master_wombat_yml)['version']

raise 'You must update the demo version in wombat.yml before your change can be promoted!' if(change_demo_ver == master_demo_ver)

include_recipe 'delivery-truck::unit'
