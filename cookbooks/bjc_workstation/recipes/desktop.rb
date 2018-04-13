#
# Cookbook Name:: bjc_workstation
# Recipe:: desktop
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Ye olde startup script
cookbook_file "#{home}\\Start_Demo.ps1" do
  action :create
  source "Start_Demo.ps1"
end

cookbook_file "#{home}\\Generate_CCRs.ps1" do
  action :create
  source "Generate_CCRs.ps1"
end

cookbook_file "#{home}\\Desktop\\email.html" do
  action :create
  source "email.html"
end

windows_shortcut "#{home}\\Desktop\\Generate_CCRs.lnk" do
  target "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
  arguments " #{home}\\Generate_CCRs.ps1"
  description "Kick off a converge loop"
end

windows_shortcut "#{home}\\Desktop\\Start_DCA.lnk" do
  target "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
  arguments " #{home}\\Start_DCA.ps1"
  description "Kick off a DCA Demo"
end

windows_shortcut "#{home}\\Desktop\\DCA_Correct.lnk" do
  target "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
  arguments " #{home}\\Start_Correct.ps1"
  description "Prepare for correct phase"
end

windows_shortcut "#{home}\\Desktop\\Finish_DCA.lnk" do
  target "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
  arguments " #{home}\\Finish_DCA.ps1"
  description "Wrap up a DCA Demo"
end

windows_shortcut "#{home}\\Desktop\\Start_CM.lnk" do
  target "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
  arguments " #{home}\\Start_CM.ps1"
  description "Start a CM Demo in AWS"
end

windows_shortcut "#{home}\\Desktop\\Start_Azure_CM.lnk" do
  target "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
  arguments " #{home}\\Start_Azure_CM.ps1"
  description "Start a CM Demo in Azure"
end

# Remove EC2 shortcuts
file "#{home}/Desktop/EC2 Feedback.website" do
  action :delete
end

file "#{home}/Desktop/EC2 Microsoft Windows Guide.website" do
  action :delete
end

# Enable ClearType
registry_key "HKEY_CURRENT_USER\\Control Panel\\Desktop" do
  values [{
    :name => "FontSmoothing",
    :type => :string,
    :data => 2
  }, {
    :name => "FontSmoothingType",
    :type => :dword,
    :data => 2
  }]
  action :create
end

# Create sample kitchen configs directory
directory "#{home}/Desktop/Test_Kitchen" do
  action :create
end

# Render sample kitchen templates
template "#{home}/Desktop/Test_Kitchen/kitchen_windows.yml" do
  action :create
  source 'kitchen_windows.yml.erb'
  variables(
    :home => home
  )
end

template "#{home}/Desktop/Test_Kitchen/kitchen_linux.yml" do
  action :create
  source 'kitchen_linux.yml.erb'
  variables(
    :home => home
  )
end

# Ensure the appropriate start-up script runs at launch
windows_shortcut 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\start me up.lnk' do
  target "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
  arguments " #{home}\\#{node['bjc_workstation']['startup']}" 
  description "Start the Chef demo"
  not_if { node['bjc_workstation']['startup'].empty? }
end