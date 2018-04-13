#
# Cookbook:: audit-wrapper
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

case node['os']
when 'linux'
  node.override['audit']['profiles'] = [ {"name" => "linux-baseline", "compliance" => "workstation-1/linux-baseline"}]
when 'windows'
  node.override['audit']['profiles'] = [ {"name" => "windows-baseline", "compliance" => "workstation-1/windows-baseline"}]
end

include_recipe 'audit'
