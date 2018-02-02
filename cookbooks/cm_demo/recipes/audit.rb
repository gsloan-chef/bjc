#
# Cookbook:: cm_demo
# Recipe:: audit
#
# Copyright:: 2017, Nick Rycar, All Rights Reserved.

# Include baseline audits from the dca_audit_baseline cookbook
# The cookbook contains per-OS triggers so that the appropriate
# windows or linux audits will be applied based on the node scanned.

include_recipe 'dca_audit_baseline::default'
