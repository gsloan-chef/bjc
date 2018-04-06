#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Enforces updating the CHANGELOG.md whenever a change is submitted.
raise 'You must update CHANGELOG.md before your change can be promoted!' if !changed_files.include?("CHANGELOG.md")

# Check that the Demo version in wombat.yml has been incremented. Only runs in Verify, since change will be merged before Build.
change_demo_ver = YAML.load_file("#{workflow_workspace_repo}/wombat.yml")['version']
master_wombat_yml = shell_out!('git show origin/master:wombat.yml', cwd: workflow_workspace_repo).stdout
master_demo_ver = YAML.load(master_wombat_yml)['version']

if ['verify'].include?(node['delivery']['change']['stage'])
  raise 'You must update the demo version in wombat.yml before your change can be promoted!' if(change_demo_ver == master_demo_ver)
end


include_recipe 'delivery-truck::unit'
