#
# Cookbook Name:: bjc_workstation
# Recipe:: berksconfig
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

directory "#{home}/.berkshelf"

file "#{home}/.berkshelf/config.json" do
  content <<-EOS
  {"ssl": {"verify": false}}
  EOS
end
