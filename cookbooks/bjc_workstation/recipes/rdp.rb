# Recipe:: rdp
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
port = 443

# Duplicate existing RDP-Tcp connection
# TODO: Refactor to make this idempotent if correct key is already present
batch 'Duplicate RDP Listener With New Name' do
  code "reg copy \"#{key}\" \"#{key}-#{port}\" /s /f"
  cwd home
  action :run
end

# Open Windows Firewall
%w[TCP UDP].each do |protocol|
  firewall_rule_name = "RDP-HTTPS-#{protocol}"

  execute 'open-static-port' do
    command "netsh advfirewall firewall add rule name=\"#{firewall_rule_name}\" dir=in action=allow protocol=#{protocol} localport=#{port}"
    returns [0, 1, 42] # *sigh* cmd.exe return codes are wonky
    not_if "netsh advfirewall firewall show rule \"#{firewall_rule_name}\""
  end
end

# Set the port number on our new listener to 443
# This requires a reboot to become functional. Shouldn't be an issue in the
# context of BJC usage, but just to be aware.
registry_key "#{key}-#{port}" do
  values [{
    name: 'PortNumber',
    type: :dword,
    data: port
  }]
  action :create
end
