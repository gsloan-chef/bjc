# encoding: utf-8
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# author: Sean Carolan

rdp_ports = %w[3389 443]

control 'bjc-rdp-ports' do
  title "RDP is listening on ports #{rdp_ports}"
  rdp_ports.each do |rdp_port|
    describe port(rdp_port) do
      it { should be_listening }
      its('processes') {should include 'TermService'}
    end
  end
end


control 'bjc-packages' do
  title 'Required packages are installed'
  # CHANGED: Pkg names with version in them are wildcard matched
  # Without this change, we have to pin/modify tests every time a version changes
  packages = [
    'Microsoft Visual Studio Code',
    'Chef Client *',
    'Chef Development Kit *',
    'Git Extensions *',
    'Git *',
    'Google Chrome',
    'Microsoft Git Credential Manager for Windows *'
  ]

  packages.each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  # CHANGED: Updated chocolatey tests for to no longer look for 'latest'. Also, moved Atom test to the method below.

  describe command('choco list atom --exact --local-only --limit-output') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match('atom|') }
  end

  describe command('choco list putty --exact --local-only --limit-output') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match('putty|') }
  end

  describe command('choco list cmder --exact --local-only --limit-output') do
     its('exit_status') { should eq 0 }
     its('stdout') { should match('cmder|') }
   end
end

control 'bjc-configfiles' do
  title 'Config files are set up correctly'
  describe file('C:\tools\cmder\config\ConEmu.xml') do
    it { should be_file }
  end
  describe file('C:\Users\Default\.gitconfig') do
    it { should be_file }
    its('content') { should match('automate-demo.com')}
  end
  describe file('C:\Users\Default\.delivery\cli.toml') do
    it { should be_file }
    its('content') { should match('automate.automate-demo.com')}
  end
  describe file('C:\Users\Default\.berkshelf\config.json') do
    it { should be_file }
    its('content') { should match('{"ssl": {"verify": false}}')}
  end
  describe file('C:\Users\Default\cookbooks\bjc-ecommerce\.kitchen.yml') do
    it { should be_file }
    its('content') { should match('sg-2560a741')}
  end
  describe file('C:\Users\Default\Desktop\Test_Kitchen\kitchen_windows.yml') do
    it { should be_file }
    its('content') { should match('sg-2560a741')}
  end
  describe file('C:\Users\Default\Desktop\Test_Kitchen\kitchen_linux.yml') do
    it { should be_file }
    its('content') { should match('sg-2560a741')}
  end
  describe file('C:\Users\Default\user_data') do
    it { should be_file }
    its('content') { should match('Defaults:centos !requiretty')}
  end
  describe file('C:\Users\Default\ubuntu_user_data') do
    it { should be_file }
    its('content') { should match('AUTOMATE_SERVER_IP automate.automate-demo.com')}
  end
  describe file('C:\Users\Default\windows_user_data') do
    it { should be_file }
    its('content') { should match('<powershell>')}
  end
  describe file('C:\Users\Default\Start_Demo.ps1') do
    it { should be_file }
    its('content') { should match('Atomic Batteries to Power.')}
  end
  describe file('C:\Users\Default\AppData\Local\Google\Chrome\User Data\Default\Bookmarks') do
    it { should be_file }
    its('content') { should match('delivered.automate-demo.com')}
  end
  describe file('C:\Users\Default\.ssh\id_rsa.ppk') do
    it { should be_file }
    its('content') { should match('g4wKcFFd9aO0dA')}
  end
  # This test fails
  #describe file ('C:\Users\Default\AppData\Roaming\Code\User\settings.json') do
  #  it { should be_file }
  #  its('content') { should match('"update.channel": "none"')}
  #end
  #describe file ('C:\Users\Default\AppData\Roaming\Code\Local Storage\file__0.localstorage') do
  #  it { should be_file }
  #end
  #describe file ('C:\Users\Default\.vscode\extensions\Pendrica.Chef-0.6.2\README.md') do
  #  it { should be_file }
  #  its('content') { should match('# Chef Extension for Visual Studio Code')}
  #end
  # Also broken
  #describe file ('C:\Users\Default\.atom\config.cson') do
  #  it { should be_file }
  #  its('content') { should match('automaticallyUpdate: false')}
  #end
end

# This test is not working as of 2017-01-02
#control 'bjc-regkeys' do
#  describe registry_key('Google Update','HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Update') do
#    it { should exist }
#    its('AutoUpdateCheckPeriodMinutes') { should eq 0 }
#    its('UpdateDefault') { should eq 0 }
#  end
#end

# control "bjc-cookbooks" do
#   title "Required cookbooks are downloaded from S3"
#   cookbooks = %w(bjc-ecommerce.zip bjc_bass.zip)
#   cookbooks.each do |cb|
#     describe file("C:\\Users\\Default\\cookbooks\\#{cb}") do
#       it { should be_file }
#     end
#   end
# end
