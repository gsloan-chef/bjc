default['audit']['fetcher'] = 'chef-server-automate'
default['audit']['reporter'] = 'chef-server-automate'

# Pin InSpec Version to known good
default['audit']['inspec_version'] = '2.2.35'

if node['os'] == 'linux'
  default['audit']['profiles'] = [
    {
      name: 'Linux Baseline',
      compliance: 'leela/linux_baseline_wrapper',
    },
  ]
elsif node['os'] == 'windows'
  default['audit']['profiles'] = [
    {
      name: 'Windows Baseline',
      compliance: 'leela/windows_baseline_wrapper',
    },
  ]
end
