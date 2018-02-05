include_recipe 'cm_demo::audit'

node.default['audit']['profiles'] += [
  {
    name: 'CIS Ubuntu Level 1',
    compliance: 'workstation-1/cis-ubuntu14.04lts-level1',
  },
  {
    name: 'CIS Ubuntu Level 2',
    compliance: 'workstation-1/cis-ubuntu14.04lts-level2',
  },
]
