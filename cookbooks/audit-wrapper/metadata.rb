name 'audit-wrapper'
maintainer 'EMEA Tech CFT'
maintainer_email 'emea+techcft@chef.io'
license 'All Rights Reserved'
description 'Attribute override wrapper of Audit cookbook'
long_description 'Use this cookbook to allow platform assessment with relevant attribute setting until the audit cookbook supports it natively.'
version '0.1.3'
chef_version '>= 12.1' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/audit-wrapper/issues'

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/audit-wrapper'

depends 'audit'