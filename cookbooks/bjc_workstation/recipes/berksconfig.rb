#
# Cookbook Name:: bjc_workstation
# Recipe:: berksconfig
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

directory "#{home}/.berkshelf"

file "#{home}/.berkshelf/config.json" do
  content <<-SSLOFF
  {"ssl": {"verify": false}}
  SSLOFF
end
