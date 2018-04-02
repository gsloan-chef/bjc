#
# Cookbook Name:: bjc_workstation
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

node.default['demo']['certs'] = %w[
  automate
  chef
  compliance
  ecomacceptance
  union
  rehearsal
  delivered
]
include_recipe 'workstation'
include_recipe 'bjc_workstation::cmder'
include_recipe 'bjc_workstation::cookbooks'
include_recipe 'bjc_workstation::gitconfig'
include_recipe 'bjc_workstation::delivery'
include_recipe 'bjc_workstation::berksconfig'
include_recipe 'bjc_workstation::putty'
include_recipe 'bjc_workstation::rdp'
include_recipe 'bjc_workstation::editors'
include_recipe 'bjc_workstation::desktop'
include_recipe 'bjc_workstation::browser'
include_recipe 'bjc_workstation::environment'
include_recipe 'bjc_workstation::kitchen_templates'
include_recipe 'bjc_workstation::freedoms'
include_recipe 'bjc_workstation::wallpaper'
include_recipe 'bjc_workstation::dca'
