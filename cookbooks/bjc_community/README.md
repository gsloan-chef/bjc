# bjc_community

This cookbook is used to add cookbooks and their dependencies to the BJC Chef Server. If you have a particular cookbook that is not part of the DCA demo, Cloud Migration demo, Risk demo, or EMEA demo that you want to pull in, simply update the `metadata.rb` or the `Berksfile` in this cookbook, and all future builds will include that cookbook and it's dependencies. 

This cookbook currently pulls in the following cookbooks:
- [chef-client cookbook](https://github.com/chef-cookbooks/chef-client)
- [Habitat cookbook](https://github.com/chef-cookbooks/habitat)

