name 'dca_audit_baseline'
maintainer 'Nick Rycar'
maintainer_email 'nrycar@chef.io'
license 'All Rights Reserved'
description 'Baseline Security Audits'
long_description 'Runs the dev-sec security baselines for linux or windows.'
version '0.1.2'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'audit'

%w( centos ubuntu windows ).each do |os|
  supports os
end
