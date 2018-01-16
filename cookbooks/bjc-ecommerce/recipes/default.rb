#
# Cookbook Name:: bjc-ecommerce
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'bjc-ecommerce::apt'
include_recipe 'bjc-ecommerce::java'
include_recipe 'bjc-ecommerce::mysql'
include_recipe 'bjc-ecommerce::tomcat'
include_recipe 'bjc-ecommerce::cart'
include_recipe 'bjc-ecommerce::ssl'
