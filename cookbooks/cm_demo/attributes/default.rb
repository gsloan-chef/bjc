default['audit']['fetcher'] = 'chef-server-automate'
default['audit']['reporter'] = 'chef-server-automate'

default['audit']['profiles'] = [
  {
    name: 'Linux Baseline',
    compliance: 'workstation-1/planex_validate',
  },
]

if node['fqdn'].include?('compute.internal')
  default['bjc-ecommerce']['company-name'] = '&#128640; Planet Express (on AWS!) &#128640;'
else
  default['bjc-ecommerce']['company-name'] = '&#128640; Planet Express (on prem!) &#128640;'
end
